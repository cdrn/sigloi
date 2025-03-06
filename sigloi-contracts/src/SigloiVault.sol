// src/Sigloi.sol
pragma solidity ^0.8.0;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./SIGUSD.sol";
import "./OracleManager.sol";

interface ILido {
    function submit(address _referral) external payable returns (uint256);
}

contract SigloiVault is Initializable, OwnableUpgradeable {
    ILido public lido;
    IERC20 public stablecoin;
    OracleManager public oracleManager;

    mapping(address => uint256) public stETHCollateral;
    mapping(address => uint256) public debtBalance;

    // Collateralization parameters
    uint256 public constant COLLATERALIZATION_RATIO = 150; // 150% minimum collateralization
    uint256 public constant LIQUIDATION_THRESHOLD = 125; // 125% liquidation threshold
    
    // Events
    event Deposited(address indexed user, uint256 amount);
    event Minted(address indexed user, uint256 amount);
    event Staked(address indexed user, uint256 stETHAmount);
    event Burned(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Liquidated(address indexed user, address indexed liquidator, uint256 debtAmount, uint256 collateralAmount);

    function initialize(
        address _lidoAddress,
        address _stablecoinAddress,
        address _oracleManagerAddress
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
        uint256 currentDebt = debtBalance[msg.sender];
        uint256 newTotalDebt = currentDebt + amount;
        
        // Collateral value is already in USD
        // amount is in SIGUSD (18 decimals)
        // Require minimum collateralization ratio
        require(
            collateralValue >= (newTotalDebt * COLLATERALIZATION_RATIO) / 100,
            "Insufficient collateral"
        );

        // Update debt balance
        debtBalance[msg.sender] = newTotalDebt;

        // Mint SIGUSD to the user
        SIGUSD(address(stablecoin)).mint(msg.sender, amount);

        emit Minted(msg.sender, amount);
    }
    
    function burn(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(debtBalance[msg.sender] >= amount, "Insufficient debt balance");
        
        // Transfer SIGUSD from user to this contract
        stablecoin.transferFrom(msg.sender, address(this), amount);
        
        // Burn the SIGUSD
        SIGUSD(address(stablecoin)).burn(address(this), amount);
        
        // Update debt balance
        debtBalance[msg.sender] -= amount;
        
        emit Burned(msg.sender, amount);
    }
    
    function withdraw(uint256 stETHAmount) external {
        require(stETHAmount > 0, "Amount must be greater than zero");
        require(stETHCollateral[msg.sender] >= stETHAmount, "Insufficient stETH collateral");
        
        // Check if withdrawal would violate minimum collateralization ratio
        uint256 debt = debtBalance[msg.sender];
        
        if (debt > 0) {
            uint256 newCollateral = stETHCollateral[msg.sender] - stETHAmount;
            uint256 newCollateralValue = getCollateralValueFromAmount(newCollateral);
            require(
                newCollateralValue >= (debt * COLLATERALIZATION_RATIO) / 100,
                "Withdrawal would violate min collateral ratio"
            );
        }
        
        // Update collateral
        stETHCollateral[msg.sender] -= stETHAmount;
        
        // Transfer stETH to user
        // In real implementation, we'd use stETH.transfer
        // For this MVP, we're simulating by transferring ETH
        payable(msg.sender).transfer(stETHAmount);
        
        emit Withdrawn(msg.sender, stETHAmount);
    }

    function getCollateralValue(address user) public returns (uint256) {
        uint256 userCollateral = stETHCollateral[user];
        return getCollateralValueFromAmount(userCollateral);
    }
    
    function getCollateralValueFromAmount(uint256 collateralAmount) public returns (uint256) {
        // TODO: un-hard code this at some point
        // Current ID is for steth/usd
        bytes32 priceFeedId = 0x846ae1bdb6300b817cee5fdee2a6da192775030db5615b94a465f53bd40850b5;
        (int64 price, uint64 confidence) = oracleManager.getLatestPrice(
            priceFeedId
        );

        require(price > 0, "Invalid oracle price");

        // In production, price is expected to be USD price with 8 decimals (e.g., 2000_00000000 for $2000)
        // stETH has 18 decimals, so we need to adjust for the difference
        return (collateralAmount * uint256(int256(price))) / 1e8; // Adjust for decimals
    }
    
    function getCollateralRatio(address user) public returns (uint256) {
        uint256 debt = debtBalance[user];
        if (debt == 0) return type(uint256).max; // If no debt, collateral ratio is infinite
        
        uint256 collateralValue = getCollateralValue(user);
        return (collateralValue * 100) / debt; // Returns ratio in percentage (e.g., 150 for 150%)
    }
    
    function isLiquidatable(address user) public returns (bool) {
        uint256 collateralRatio = getCollateralRatio(user);
        return collateralRatio < LIQUIDATION_THRESHOLD;
    }
    
    function liquidate(address user, uint256 debtAmount) external {
        require(debtAmount > 0 && debtAmount <= debtBalance[user], "Invalid debt amount");
        require(isLiquidatable(user), "Position not liquidatable");
        
        // Calculate collateral to seize
        // We give a 5% bonus to liquidators - they get slightly more collateral than the debt is worth
        uint256 collateralValue = (debtAmount * 105) / 100; // 5% bonus
        
        // Get current stETH price
        bytes32 priceFeedId = 0x846ae1bdb6300b817cee5fdee2a6da192775030db5615b94a465f53bd40850b5;
        (int64 price, ) = oracleManager.getLatestPrice(priceFeedId);
        
        // Calculate stETH amount to seize
        uint256 stETHToSeize = (collateralValue * 1e8) / uint256(int256(price));
        require(stETHToSeize <= stETHCollateral[user], "Not enough collateral to seize");
        
        // Transfer SIGUSD from liquidator to this contract
        stablecoin.transferFrom(msg.sender, address(this), debtAmount);
        
        // Burn the SIGUSD
        SIGUSD(address(stablecoin)).burn(address(this), debtAmount);
        
        // Update user's debt and collateral
        debtBalance[user] -= debtAmount;
        stETHCollateral[user] -= stETHToSeize;
        
        // Transfer seized stETH to liquidator
        // In real implementation, we'd use stETH.transfer
        payable(msg.sender).transfer(stETHToSeize);
        
        emit Liquidated(user, msg.sender, debtAmount, stETHToSeize);
    }
}
