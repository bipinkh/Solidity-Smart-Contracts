pragma solidity ^0.4.17;

contract users{
    
    struct userDetails{
        bool isAccountActive;   //false if deleted
        bool privateAccount;    //if true, do not show details
        string name;
        string country;
    }
    
    mapping (address => userDetails) userDetailMap;  // user address to details mapping, optional to add
    address contractOwner;
    
    /* constructor */
    function users() public{
        contractOwner = msg.sender;
    }
    
    /* modifiers*/
     modifier userExists(address add){
        require( userDetailMap[add].isAccountActive == true);
        _;
    }
    modifier userVisible(address add){
        require( userDetailMap[add].privateAccount == false);
        _;
    }

    /* functions */
    function registerMe() public returns (bool){
        var udetails = userDetailMap[msg.sender];
        udetails.isAccountActive = true;
        return true;
    }
    
    function setMyDetails(bool privateAccount, string name, string country) public userExists(msg.sender) returns(bool){
        var udetails = userDetailMap[msg.sender];
        udetails.privateAccount = privateAccount;
        udetails.name = name; 
        udetails.country = country;
        return true;
    }
    
    function getUserDetails(address userAddress) view public userExists(msg.sender) userVisible(msg.sender) returns(string name, string country){
        return (userDetailMap[userAddress].name , userDetailMap[userAddress].country);
    }
    
    function deleteMe() public userExists(msg.sender) returns (bool){
        var udetails = userDetailMap[msg.sender];
        udetails.isAccountActive = false;
        return true;
    }
}

