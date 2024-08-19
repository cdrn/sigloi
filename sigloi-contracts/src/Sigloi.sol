// src/Sigloi.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Sigloi {
    mapping(address => uint256) public collateral;

    event Deposited(address indexed user, uint256 amount);

    function deposit() external payable {
        collateral[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getCollateral(address user) external view returns (uint256) {
        return collateral[user];
    }
}
