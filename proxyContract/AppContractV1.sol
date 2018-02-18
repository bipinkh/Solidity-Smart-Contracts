pragma solidity ^0.4.17;

import "browser/Upgradable.sol";
import "browser/DataStore.sol";


contract AppContractV1 is Upgradeable {
    
    DataStore dStore;
    
    function initialize() {
        // do some initialization task here if required
    }
    
    function getUint() public constant returns (uint) {
        return dStore.getUIntValue(sha3("MyData"));
    }
    
    function setUint(uint256 value) {
        // use data store to store values instead of storage
        dStore.setUIntValue(sha3("MyData"),value);
    }
    
    function check() returns (string){
        return "bipin";
    }
}
