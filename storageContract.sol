pragma solidity^0.4.0;
contract ledger{
    
    
    /* creating map to store data of different datatypes */
    
    struct numStruct {  mapping(bytes32=>uint) numValue; }
    mapping(address=>numStruct) numDatabase;
    
    struct stringStruct {  mapping(bytes32=>string) strValue; }
    mapping(address=>stringStruct) stringDatabase;
    

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
    function registerMe() public returns (bool success){
        //prevent already registered user to re-register
        if(registeredUsers[msg.sender]){   
            return false;
        }else{
             registeredUsers[msg.sender]=true;
             return true;
        }
    }
    
    /* remove  existing user */
    function removeMe() public returns (bool success){
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
            numDatabase[msg.sender].numValue[key] = value;
            return true;
        }else{
            return false;
        }
    }
    
    function setString(bytes32 key, string value) public returns (bool success){
        if (registeredUsers[msg.sender]){   //allow only registered user to set value
            stringDatabase[msg.sender].strValue[key] = value;
            return true;
        }else{
            return false;
        }
    }
    
    


    /* getter for database */
    
    function getNumber(bytes32 key) public returns (uint value){
        if (registeredUsers[msg.sender]){   
           return numDatabase[msg.sender].numValue[key];
        }else{
            return 0;
        }
    }
    
    function getString(bytes32 key) public returns (string value){
        if (registeredUsers[msg.sender]){   
           return stringDatabase[msg.sender].strValue[key];
        }else{
            return "null";
        }
    }
    

}
