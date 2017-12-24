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
    function registerUser() public returns (bool){
        var udetails = userDetailMap[msg.sender];
        udetails.isAccountActive = true;
        return true;
    }
    
    function setUserDetails(bool privateAccount, string name, string country) public userExists(msg.sender) returns(bool){
        var udetails = userDetailMap[msg.sender];
        udetails.privateAccount = privateAccount;
        udetails.name = name; 
        udetails.country = country;
        return true;
    }
    
    function getUserDetails(address userAddress) view public userExists(msg.sender) userVisible(msg.sender) returns(string name, string country){
        return (userDetailMap[userAddress].name , userDetailMap[userAddress].country);
    }
    
    function deketeUser() public userExists(msg.sender) returns (bool){
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
    modifier noDuplicateMedia(bytes32 hash){                                  // check if that media already existed
        require( mediaDetailsMap[hash].isAvailable != true );
        _;
    } 

    /* functions */
    
    // upload a media
    function createMedia(bytes32 hash, bool sellable, uint price) public noDuplicateMedia(hash) returns(bool){
        mediaDetails md = mediaDetailsMap[hash];
        md.isAvailable = true;
        md.isSellable = sellable;
        md.price = price;
        md.originalAuthor = msg.sender;
        md.currentAuthor = msg.sender;
        return true;
    }
    
    //delete a media
    function deleteMedia(bytes32 hash) public isAvailable(hash) returns(bool){
        var md = mediaDetailsMap[hash];
        md.isAvailable = false;
        return true;
    }
    
    //get the price of media
    function getPriceOf(bytes32 hash) view public isAvailable(hash) isSellable(hash) returns(uint){   
        return mediaDetailsMap[hash].price;
    }
    
    //get the price of media
    function getOwnerOf(bytes32 hash) view public isAvailable(hash) returns(address){   
        return mediaDetailsMap[hash].currentAuthor;
    }
    
    //set new price
    function setNewPriceOf(bytes32 hash, uint newPrice) public isAvailable(hash) legalCurrentOwner(hash) returns(bool){
        var md = mediaDetailsMap[hash];
        md.price = newPrice;
        return true;
    }
    
     //set new sellable status
    function setSellableStatusOf(bytes32 hash, bool sellStatus) public isAvailable(hash) legalCurrentOwner(hash) returns(bool){
        var md = mediaDetailsMap[hash];
        md.isSellable = sellStatus;
        return true;
    }
    
    //change the media owner
    function _changeOwner(bytes32 hash)internal isAvailable(hash) isSellable(hash) returns(bool){
        var md = mediaDetailsMap[hash];
        md.currentAuthor = msg.sender;

        return true;
    }
    
}



contract ownershipTransfer is users, media{
    
    
    struct transaction{         //a single transaction entry
        uint transactionID;
        uint price;
        address from;
        address to;
        uint datestamp;
    }
    
    struct mediaTransaction{    
        uint lastTxnId;                                  //also the total number of transaction of that media
        mapping (uint => transaction) mediaHistory;  // mapping to all transactions of a particular media
    }
    
    mapping (bytes32 => mediaTransaction ) allHistory;  //mapping to store all history of all media
    
    
    function buyMedia(bytes32 hash) public isAvailable(hash) isSellable(hash) payable userExists(msg.sender) returns(bool){
        
        uint sellPrice = getPriceOf(hash);  //check if sent price is greater than the selling price
        require (msg.value >= sellPrice);
        
        address owner = getOwnerOf(hash);   //get current owner of media and transfer fund to it
        require(owner != msg.sender);       //owner cannot buy his own media
        owner.transfer(msg.value);             
        
        require( _changeOwner(hash) );      //change ownership of media
        
        _storeATransaction(hash,sellPrice,owner,msg.sender);    //record that transaction
        
        return true;
    }
    
    function _storeATransaction(bytes32 hash, uint price, address from, address to) internal returns(bool){
        mediaTransaction resource = allHistory[hash];                
        
        uint currentTxnId = resource.lastTxnId + 1;
        resource.lastTxnId = currentTxnId;
        
        transaction newTransaction = resource.mediaHistory[currentTxnId];    //create a new transaction
        
        newTransaction.transactionID = currentTxnId;
        newTransaction.price = price;
        newTransaction.from = from;
        newTransaction.to = to;
        newTransaction.datestamp = now;
        
        return true;
    }
    
    function getNumberOfSoldTimes(bytes32 hash) public constant returns(uint txnTimes){
        mediaTransaction media = allHistory[hash];
        return media.lastTxnId;
    }
    
    
    function getPreviousOwners(bytes32 hash) public isAvailable(hash) constant returns(address[]){
        address[] allOwners;
        
        mediaTransaction media = allHistory[hash];
        
        for (uint i=0; i<=media.lastTxnId; i++){
            allOwners.push(media.mediaHistory[i].from);
        }
        
        return allOwners;
    }
    
    
    
}

