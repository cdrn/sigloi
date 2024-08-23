// src/SIGUSD.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SIGUSD is ERC20, Ownable {
    constructor(
        address initialOwner
    ) Ownable(initialOwner) ERC20("SIGUSD", "SIGUSD") {}

    // Allow SigloiVault to mint tokens
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Allow SigloiVault to burn tokens
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
