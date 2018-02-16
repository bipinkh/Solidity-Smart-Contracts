pragma solidity ^0.4.17;

contract Upgradeable {
    
    address _dest;
    address _store;
    
    function initialize();
    
    
    function dataStore(address _storeAddress) internal {
    _store = _storeAddress;
    }
    
    
    function replace(address target) internal {
    _dest = target;
    target.delegatecall(bytes4(sha3("initialize()")));
    }
    
}
