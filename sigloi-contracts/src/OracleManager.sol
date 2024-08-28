// contracts/OracleManager.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol"; // Import Pyth interface

contract OracleManager is Initializable, OwnableUpgradeable {
    IPyth public pyth;

    // Event for tracking oracle changes
    event OracleChanged(address indexed newOracle);

    // Initialize the OracleManager with the Pyth address
    function initialize(address _pythAddress) public initializer {
        __Ownable_init();
        pyth = IPyth(_pythAddress);
    }

    // Function to set a new oracle
    function setOracle(address _pythAddress) external onlyOwner {
        pyth = IPyth(_pythAddress);
        emit OracleChanged(_pythAddress);
    }

    // Function to fetch the latest price from Pyth
    function getLatestPrice(
        bytes32 priceFeedId
    ) public view returns (int64 price, uint64 confidence) {
        PythStructs.Price memory pythPrice = pyth.getPrice(priceFeedId);
        return (pythPrice.price, pythPrice.conf);
    }

    // Future-proof: You could implement similar functions for other oracle providers here
}
