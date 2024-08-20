// test/SigloiVault.t.sol
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "../src/SigloiVault.sol";

contract SigloiVaultTest is Test {
    Sigloi sigloi;
    IERC20Upgradeable stablecoin;
    ILido lido;

    address user = address(1);

    function setUp() public {
        // Deploy mocks for Lido and Stablecoin
        lido = ILido(address(new MockLido()));
        stablecoin = IERC20Upgradeable(address(new MockStablecoin()));

        // Initialize Sigloi contract with mock Lido and Stablecoin
        sigloi = new Sigloi();
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
