pragma solidity ^0.4.17;



contract DataStore{
    

    mapping(bytes32 => uint) UIntStorage;

    function getUIntValue(bytes32 record) constant returns (uint){
        return UIntStorage[record];
    }
    
    //this is just for test to see if value is being stored in this contract
    function getUIntValueDirect(string name) constant returns (uint){
        return UIntStorage[sha3(name)];
    }

    function setUIntValue(bytes32 record, uint value)
    {
        UIntStorage[record] = value;
    }

}
