pragma solidity ^0.4.0;

contract Storage {
    uint storedData;

    function setStoredData(uint _storedData) {
        storedData = _storedData;
    }

    function getStoredData() returns (uint) {
        return storedData;
    }
}
