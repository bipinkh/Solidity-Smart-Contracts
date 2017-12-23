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



contract media{
     
    struct mediaDetails{
        bool isAvailable;   //false if deleted
        bool isSellable;
        uint price;
        address originalAuthor;
        address currentAuthor;
    }
    
    mapping (bytes32 => mediaDetails) mediaDetailsMap;  //media hash to media details
    address contractOwner;
    
    /* constructor */
    function media() public{
        contractOwner = msg.sender;
    }
    
    /* modifiers*/
    modifier isSellable(bytes32 hash){                                  // if it is available for trade
        require( mediaDetailsMap[hash].isSellable == true );
        _;
    }
    modifier isAvailable(bytes32 hash){                                  // media exists or is not deleted
        require( mediaDetailsMap[hash].isAvailable == true );
        _;
    }   
    modifier legalCurrentOwner(bytes32 hash){                           // if the media belongs to the correct current Author
        require( mediaDetailsMap[hash].currentAuthor == msg.sender);
        _;
    }
    modifier noDuplicate(bytes32 hash){                                  // check if that media already existed
        require( mediaDetailsMap[hash].isAvailable != true );
        _;
    } 



    /* functions */
    

    // upload a media
    function createMedia(bytes32 hash, bool sellable, uint price) public noDuplicate(hash) returns(bool){
        mediaDetails md = mediaDetailsMap[hash];
        md.isAvailable = true;
        md.isSellable = sellable;
        md.price = price;
        md.originalAuthor = msg.sender;
        md.currentAuthor = msg.sender;
    }
    
    //delete a media
    function deleteMedia(bytes32 hash) public isAvailable(hash) returns(bool){
        mediaDetails md = mediaDetailsMap[hash];
        md.isAvailable = false;
        return true;
    }
    
    //get the price of media
    function getPrice(bytes32 hash) public isAvailable(hash) isSellable(hash) returns(uint){   
        return mediaDetailsMap[hash].price;
    }
    
    //get the price of media
    function getOwner(bytes32 hash) public isAvailable(hash) returns(address){   
        return mediaDetailsMap[hash].currentAuthor;
    }
    
    //set new price
    function setNewPrice(bytes32 hash, uint newPrice) public isAvailable(hash) legalCurrentOwner(hash) returns(bool){
        mediaDetails md = mediaDetailsMap[hash];
        md.price = newPrice;
        return true;
    }
    
     //set new sellable status
    function setSellableStatus(bytes32 hash, bool sellStatus) public isAvailable(hash) legalCurrentOwner(hash) returns(bool){
        mediaDetails md = mediaDetailsMap[hash];
        md.isSellable = sellStatus;
        return true;
    }
    
    //buy the media
    function buy(bytes32 hash)public payable isAvailable(hash) isSellable(hash) returns(bool){
        mediaDetails md = mediaDetailsMap[hash];
        require(msg.value > md.price);              //check if price is enough to buy
        
        md.currentAuthor.transfer(msg.value);
        md.currentAuthor = msg.sender;

        return true;
    }
    
    
}

