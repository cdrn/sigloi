// test/SigloiVault.t.sol
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // Use regular IERC20 for testing
import "../src/SigloiVault.sol";

contract MockLido is ILido {
    function submit(
        address _referral
    ) external payable override returns (uint256) {
        // Mock Lido's submit function: return stETH equal to the amount of ETH sent
        return msg.value;
    }
}

contract MockStablecoin is ERC20 {
    constructor() ERC20("Mock SIGUSD", "MSIGUSD") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract SigloiVaultTest is Test {
    SigloiVault sigloi;
    MockStablecoin stablecoin;
    MockLido lido;

    address user = address(1);

    function setUp() public {
        // Deploy mocks for Lido and Stablecoin
        lido = new MockLido();
        stablecoin = new MockStablecoin();

        // Initialize Sigloi contract with mock Lido and Stablecoin
        sigloi = new SigloiVault();
        sigloi.initialize(address(lido), address(stablecoin));

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
        uint256 stETHCollateral = sigloi.getCollateralValue(user);
        assertEq(
            stETHCollateral,
            5 ether,
            "stETH collateral not updated correctly"
        );
    }

    function testMintSuccess() public {
        // Simulate user depositing and staking ETH
        vm.deal(user, 10 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 10 ether}();

        // Mint SIGUSD - user should have enough collateral
        vm.prank(user);
        sigloi.mint(4 ether); // 150% collateral should allow minting 4 SIGUSD from 10 ETH

        // Check that SIGUSD was minted
        assertEq(stablecoin.balanceOf(user), 4 ether, "Minting failed");
    }

    function testMintFail() public {
        // Simulate user depositing and staking ETH
        vm.deal(user, 5 ether);
        vm.prank(user);
        sigloi.depositAndStake{value: 5 ether}();

        // Try minting SIGUSD - should fail due to insufficient collateral
        vm.prank(user);
        vm.expectRevert("Insufficient collateral");
        sigloi.mint(4 ether); // 150% collateral is insufficient with only 5 ETH staked
    }
}
