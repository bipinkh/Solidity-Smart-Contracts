pragma solidity ^0.4.17;

import "browser/Upgradable.sol";


contract AppContractV1 is Upgradeable {
    uint256 myData;
    
    function initialize() {
        // do some initialization task here if required
    }
    
    function getUint() public constant returns (uint) {
        return myData;
    }
    
    function setUint(uint256 value) {
        // use data store to store values instead of storage
        myData = value;
    }
    
    function check() returns (string){
        return "bipin";
    }
}
