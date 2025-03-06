// test/SigloiVault.t.sol
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // Use regular IERC20 for testing
import "../src/SigloiVault.sol";
import "../src/OracleManager.sol";

contract MockLido is ILido {
    function submit(
        address _referral
    ) external payable override returns (uint256) {
        // Mock Lido's submit function: return stETH equal to the amount of ETH sent
        return msg.value;
    }
}

contract MockStablecoin is ERC20 {
    constructor() ERC20("Mock SIGUSD", "MSIGUSD") {
        _mint(address(this), 100000 ether); // Pre-mint 100 SIGUSD to the contract
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract MockOracleManager is OracleManager {
    int64 private mockPrice;
    uint64 private mockConfidence;

    function setMockPrice(int64 _price, uint64 _confidence) external {
        mockPrice = _price;
        mockConfidence = _confidence;
    }

    function getLatestPrice(
        bytes32 /* priceFeedId */
    ) public view override returns (int64 price, uint64 confidence) {
        return (mockPrice, mockConfidence);
    }
}

contract SigloiVaultTest is Test {
    SigloiVault sigloi;
    MockStablecoin stablecoin;
    MockLido lido;
    MockOracleManager oracleManager;

    address user = address(1);

    function setUp() public {
        // Deploy mocks for Lido and Stablecoin
        lido = new MockLido();
        stablecoin = new MockStablecoin();
        oracleManager = new MockOracleManager();

        // Set eth price for testing
        oracleManager.setMockPrice(100 * 1e8, 1); // 100 bucks per staked eth with a confidence of 1

        // Initialize Sigloi contract with mock Lido and Stablecoin
        sigloi = new SigloiVault();
        sigloi.initialize(
            address(lido),
            address(stablecoin),
            address(oracleManager)
        );
        
        // Pre-mint stablecoin to vault for tests
        stablecoin.mint(address(sigloi), 100 ether);

        // Label user address for clarity in tests
        vm.label(user, "User");
    }

    function testInitialize() public {
        // Test that the contract initializes correctly
        assertEq(
            address(sigloi.lido()),
            address(lido),
            "Lido not set correctly"
        );
        assertEq(
            address(sigloi.stablecoin()),
            address(stablecoin),
            "Stablecoin not set correctly"
        );
    }

    function testDepositAndStake() public {
        // Simulate user depositing and staking ETH
        vm.deal(user, 10 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 5 ether}();

        // Check stETH collateral is updated correctly
        uint256 userStETHCollateral = sigloi.stETHCollateral(user);
        assertEq(
            userStETHCollateral,
            5 ether,
            "stETH collateral not updated correctly"
        );
        
        // Check collateral value with price of $100 per ETH
        uint256 collateralValue = sigloi.getCollateralValue(user);
        assertEq(collateralValue, 5 ether * 100, "Collateral value incorrect");
    }

    function testMintSuccess() public {
        // Simulate user depositing and staking ETH
        vm.deal(user, 10 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 10 ether}();

        // Mint SIGUSD - user should have enough collateral
        vm.prank(user);
        sigloi.mint(4 ether); // 150% collateral should allow minting 4 SIGUSD from 10 ETH

        // Check that SIGUSD was transferred to the user's account
        assertEq(stablecoin.balanceOf(user), 4 ether, "Minting failed");
        
        // Check that debt balance was updated correctly
        assertEq(sigloi.debtBalance(user), 4 ether, "Debt balance not updated correctly");
    }
    
    function testBurnAndWithdraw() public {
        // Setup: User deposits collateral and mints SIGUSD
        vm.deal(user, 10 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 10 ether}();
        
        vm.prank(user);
        sigloi.mint(4 ether);
        
        // User approves SIGUSD to be spent by vault
        vm.prank(user);
        stablecoin.approve(address(sigloi), 4 ether);
        
        // User burns 2 SIGUSD
        vm.prank(user);
        sigloi.burn(2 ether);
        
        // Check debt balance decreased
        assertEq(sigloi.debtBalance(user), 2 ether, "Debt balance not decreased correctly");
        
        // Check SIGUSD balance decreased
        assertEq(stablecoin.balanceOf(user), 2 ether, "SIGUSD balance not decreased correctly");
        
        // Now user should be able to withdraw some collateral while maintaining >150% ratio
        // With 10 ETH @ $100 = $1000 collateral and $200 debt, can withdraw up to ~6.5 ETH
        
        uint256 userBalanceBefore = user.balance;
        
        vm.prank(user);
        sigloi.withdraw(5 ether);
        
        // Check collateral was decreased
        assertEq(sigloi.stETHCollateral(user), 5 ether, "Collateral not decreased correctly");
        
        // Check ETH was received (in real implementation this would be stETH)
        assertEq(user.balance - userBalanceBefore, 5 ether, "ETH not received");
    }
    
    function testWithdrawTooMuch() public {
        // Setup: User deposits collateral and mints SIGUSD
        vm.deal(user, 10 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 10 ether}();
        
        vm.prank(user);
        sigloi.mint(4 ether);
        
        // Try to withdraw too much collateral
        vm.prank(user);
        (bool success, ) = address(sigloi).call(
            abi.encodeWithSelector(sigloi.withdraw.selector, 8 ether)
        );
        assertFalse(success, "Withdrawal should have failed");
    }
    
    function testLiquidation() public {
        address liquidator = address(2);
        vm.label(liquidator, "Liquidator");
        
        // Setup: User deposits collateral and mints SIGUSD
        vm.deal(user, 10 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 10 ether}();
        
        vm.prank(user);
        sigloi.mint(6 ether); // Nearly maxed out - 60% LTV
        
        // Price drops dramatically (from $100 to $15) to ensure liquidation threshold is crossed
        oracleManager.setMockPrice(15 * 1e8, 1);
        
        // Verify position is now undercollateralized (collateral value $150, debt $600)
        uint256 ratio = sigloi.getCollateralRatio(user);
        console.log("Collateral ratio:", ratio);
        assertLt(ratio, sigloi.LIQUIDATION_THRESHOLD(), "Position should be under liquidation threshold");
        
        // Prepare liquidator
        vm.deal(liquidator, 1 ether);
        stablecoin.mint(liquidator, 6 ether);
        
        vm.prank(liquidator);
        stablecoin.approve(address(sigloi), 6 ether);
        
        // Get liquidator's balance before
        uint256 liquidatorBalanceBefore = liquidator.balance;
        
        // Liquidate half the position
        vm.prank(liquidator);
        sigloi.liquidate(user, 3 ether);
        
        // Check user's debt decreased
        assertEq(sigloi.debtBalance(user), 3 ether, "User debt not decreased correctly");
        
        // Check liquidator received stETH with 5% bonus
        // 3 SIGUSD at $1 each with 5% bonus = $3.15 worth of stETH
        // At $15 per stETH, should receive ~0.21 stETH
        uint256 expectedStETH = (3 ether * 105 * 1e8) / (100 * 15 * 1e8);
        assertApproxEqRel(
            liquidator.balance - liquidatorBalanceBefore,
            expectedStETH,
            0.01e18, // 1% tolerance for rounding errors
            "Liquidator didn't receive correct amount of stETH"
        );
    }

    function testMintFail() public {
        // Simulate user depositing and staking ETH (worth $500 at our price of $100 per ETH)
        vm.deal(user, 5 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 5 ether}();

        // Get current collateral value
        uint256 collateralValue = sigloi.getCollateralValue(user);
        
        // Calculate max mintable based on 150% collateralization
        uint256 maxMintable = (collateralValue * 100) / 150;
        
        // Try minting more than allowed - should fail due to insufficient collateral
        vm.prank(user);
        vm.expectRevert("Insufficient collateral");
        sigloi.mint(maxMintable + 1 ether);
    }
}
