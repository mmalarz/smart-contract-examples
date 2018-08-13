pragma solidity ^0.4.0;

contract Storage {
    uint storedData;

    function setStoredData(uint _storedData) public {
        storedData = _storedData;
    }

    function getStoredData() public view returns (uint) {
        return storedData;
    }
}
