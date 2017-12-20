pragma solidity^0.4.0;
contract ledger{
    
    
    /* creating map to store data of different datatypes */
    struct numStruct {  mapping(bytes32=>uint) num; }
    mapping(address=>numStruct) numData;

    /* map to store address of registered user */
    mapping(address=>bool) registeredUsers;
    
    /*contract owner address*/
    address contractOwner;
    
    /* constructor to store owner address */
    function ledger() public{
        contractOwner=msg.sender;
        registeredUsers[contractOwner]=true;
    }
    
    
    /* add new user */
    function registerUser() public returns (bool success){
        //prevent already registered user to re-register
        if(registeredUsers[msg.sender]){   
            return false;
        }else{
             registeredUsers[msg.sender]=true;
             return true;
        }
    }
    
    /* remove  existing user */
    function removeUser() public returns (bool success){
        //prevent unregistered user to delete
        if(registeredUsers[msg.sender]){
            registeredUsers[msg.sender]=false;
            return true;
        }else{
            return false;
        }
    }
    

    /* setter for database */
    
    function setNumber(bytes32 key, uint value) public returns (bool success){
        if (registeredUsers[msg.sender]){   //allow only registered user to set value
            numData[msg.sender].num[key] = value;
            return true;
        }else{
            return false;
        }
    }
    


    /* getter for database */
    
    function getNumber(bytes32 key) public returns (uint val){
        if (registeredUsers[msg.sender]){   
           return numData[msg.sender].num[key];
        }else{
            return 0;
        }
    }

}
