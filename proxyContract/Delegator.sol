pragma solidity ^0.4.17;

import "browser/Upgradable.sol";


contract Delegator is Upgradeable {
    
    uint256 public myData;
    
        function Delegator(address target, address datastore) {
            replace(target);
            dataStore(datastore);
        }

        function initialize() {
            // This is just a proxy, nothing to initialize here
            revert;
        }

        function (){
           var target = _dest;
            assembly {
                calldatacopy(0x0, 0x0, calldatasize)
                let success := delegatecall(sub(gas, 10000), target, 0x0, calldatasize, 0, 0)
                let retSz := returndatasize
                returndatacopy(0, 0, retSz)
                switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
            }
        }

    
}
