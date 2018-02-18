pragma solidity ^0.4.17;

import "browser/Delegator.sol";

contract runner{
    
    address del;
    
    function runner(address delegator){
        del = delegator;
    }
    
    function setInt(uint256 a) returns (uint){
       del.call(bytes4(sha3("setUint(uint256)")), a);
    }

    
}
