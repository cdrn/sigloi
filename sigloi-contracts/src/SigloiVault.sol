// src/Sigloi.sol
pragma solidity ^0.8.0;

import "@openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";

import "./SIGUSD.sol";

interface ILido {
    function submit(address _referral) external payable returns (uint256);
}

contract SigloiVault is Initializable, OwnableUpgradeable {
    ILido public lido;
    IERC20 public stablecoin;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public stETHCollateral;

    event Deposited(address indexed user, uint256 amount);
    event Minted(address indexed user, uint256 amount);
    event Staked(address indexed user, uint256 stETHAmount);

    function initialize(
        address _lidoAddress,
        address _stablecoinAddress
    ) public initializer {
        __Ownable_init(msg.sender);
        lido = ILido(_lidoAddress); // Lido contract address
        stablecoin = SIGUSD(_stablecoinAddress); // SIGUSD contract address
        oracleManager = OracleManager(_oracleManagerAddress);
    }

    function depositAndStake() external payable {
        require(msg.value > 0, "No ETH sent");

        // stake eth with lido
        uint256 stETHReceived = lido.submit{value: msg.value}(address(0)); // stake and receive stETH

        // update user collateral
        stETHCollateral[msg.sender] += stETHReceived;

        emit Deposited(msg.sender, msg.value);
        emit Staked(msg.sender, stETHReceived);
    }

    function mint(uint256 amount) external {
        uint256 collateralValue = getCollateralValue(msg.sender);
        require(
            collateralValue * 100 >= amount * 150,
            "Insufficient collateral"
        ); // Ensure 150% collateral

        // mint SIGUSD to the user
        stablecoin.transfer(msg.sender, amount);

        emit Minted(msg.sender, amount);
    }

    function getCollateralValue(
        address user,
        bytes32 priceFeedId
    ) public view returns (uint256) {
        (int64 price, ) = oracleManager.getLatestPrice(priceFeedId);

        // Example calculation based on fetched price
        uint256 stETHCollateral = stETHCollateral[user];
        require(price > 0, "Invalid oracle price");

        return (stETHCollateral * uint256(price)) / 1e18; // Adjust for decimals
    }
}
