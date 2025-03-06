// contracts/OracleManager.sol
pragma solidity ^0.8.0;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol"; // Import Pyth interface

contract OracleManager is Initializable, OwnableUpgradeable {
    IPyth public pyth;

    // Event for tracking oracle changes
    event OracleChanged(address indexed newOracle);

    // Initialize the OracleManager with the Pyth address
    function initialize(address _pythAddress) public initializer {
        __Ownable_init(msg.sender);
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
    ) public virtual returns (int64 price, uint64 confidence) {
        PythStructs.Price memory pythPrice = pyth.getPriceNoOlderThan(
            priceFeedId,
            60
        );
        return (pythPrice.price, pythPrice.conf);
    }

    // Future-proof: add other oracles
}
