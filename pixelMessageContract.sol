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
     modifier userDontExists(address add){
        require( userDetailMap[add].isAccountActive == false);
        _;
    }
    modifier userVisible(address add){
        require( userDetailMap[add].privateAccount == false);
        _;
    }

    /* functions */
    function registerMe() public userDontExists(msg.sender) returns(bool){
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
    
    function deketeMe() public userExists(msg.sender) returns (bool){
        var udetails = userDetailMap[msg.sender];
        udetails.isAccountActive = false;
        return true;
    }
}


contract media{
    
    struct mediaDetails{            //made separate for each copy of media
        bool isAvailable;           //false if deleted
        bool isSellable;
        uint price;
    }
    
     struct mediaRoot{
         address originalAuthor;
         uint maxAllowedCopies;  // maximum number the original copies can be sold by the original author
         uint soldCopies;    //copies already sold
         mapping (address => uint) copiesMap;                   //copy author to copy number
         mapping (uint => mediaDetails) mediaDetailsMap;    //copy number to copyDetails.
     }
     
    mapping (bytes32 => mediaRoot) mediaRootMap;
    
    /* modifiers*/
    
    modifier isSellable(bytes32 hash, address usr){                 // if it is available for trade
        var root = mediaRootMap[hash];
        var copyNum = root.copiesMap[usr];
        require( root.mediaDetailsMap[copyNum].isSellable == true );
        _;
    }
    modifier isAvailable(bytes32 hash, address usr){                // media exists for that user
        var root = mediaRootMap[hash];
        var copyNum = root.copiesMap[usr];
        require( root.mediaDetailsMap[copyNum].isAvailable == true );
        _;
    }
    
    modifier legalCurrentOwner(bytes32 hash, address usr){          // media belongs to the correct current Author
        var root = mediaRootMap[hash];
        var copyNum = root.copiesMap[usr];
        require(copyNum != 0);                                      // the given address should be mapped to a valid copy number
        _;
    }
    
    modifier mediaDoesntExist(bytes32 hash){                                  // check if that media already existed
        require( mediaRootMap[hash].originalAuthor == 0x0  );
        _;
    } 
    modifier mediaExists(bytes32 hash){                                             // if the media already exists
        require( mediaRootMap[hash].originalAuthor !=0x0 );
        _;
    }
    

    /* functions */
    
    // upload a media
    function createMedia(bytes32 hash, bool sellable, uint price, uint maxAllowedCopies) 
        public mediaDoesntExist(hash) returns(bool){
        
        //create media root
        var root = mediaRootMap[hash];
        root.originalAuthor = msg.sender;
        root.maxAllowedCopies = maxAllowedCopies; //copynumber 1 is associated with original Author
        root.soldCopies=0;
        
        //create first original copy details
        uint copyNum = 1;                           //1st copy of the original media
        var md = root.mediaDetailsMap[copyNum];   //create details of original copy
        md.isAvailable = true;
        md.isSellable = sellable;
        md.price = price;
        return true;
    }
    
    //delete a media
    function deleteMedia(bytes32 hash) public isAvailable(hash, msg.sender) legalCurrentOwner(hash, msg.sender) returns(bool){
        //make that particular copy deleted
        var copyNum = mediaRootMap[hash].copiesMap[msg.sender];
        var md = mediaRootMap[hash].mediaDetailsMap[copyNum];
        md.isAvailable = false;
        return true;
    }
    
    //get the price of media
    function getPriceOf(bytes32 hash, address owner) view public isAvailable(hash, owner) isSellable(hash, owner) returns(uint){   
         var copyNum = mediaRootMap[hash].copiesMap[owner];
        return mediaRootMap[hash].mediaDetailsMap[copyNum].price;
    }
    
    function getOriginalPriceOf(bytes32 hash) view public returns(uint){
        var root = mediaRootMap[hash];
        var num = getPriceOf(hash,root.originalAuthor);
        return num;
    }
    
    //get the sold copies of any media
    function getSoldCopiesNumber(bytes32 hash) view public mediaExists(hash) returns(uint){   
        return mediaRootMap[hash].soldCopies;
    }
    
    //get the original author of media
    function getOriginalOwnerOf(bytes32 hash) view public mediaExists(hash) returns(address){   
        var root = mediaRootMap[hash];
        return root.originalAuthor;
    }
    
    
    //get mediaCopyNumber
    function _getMediaCopyNumber(bytes32 hash, address usr) view public mediaExists(hash) returns(uint){   
        return mediaRootMap[hash].copiesMap[usr];
    }
    
    //set new price
    function setNewPriceOf(bytes32 hash, uint newPrice) public legalCurrentOwner(hash,msg.sender) isAvailable(hash, msg.sender)  returns(bool){
        var copyNum = mediaRootMap[hash].copiesMap[msg.sender];
        var md = mediaRootMap[hash].mediaDetailsMap[copyNum];
        md.price = newPrice;
        return true;
    }
    
     //set new sellable status
    function setSellableStatusOf(bytes32 hash, bool sellStatus) public legalCurrentOwner(hash,msg.sender) isAvailable(hash, msg.sender) returns(bool){
        var copyNum = mediaRootMap[hash].copiesMap[msg.sender];
        var md = mediaRootMap[hash].mediaDetailsMap[copyNum];
        md.isSellable = sellStatus;
        return true;
    }
    
    //change the media owner
    function _changeOwner(bytes32 hash, address from, address to)internal legalCurrentOwner(hash,from) isAvailable(hash, from) returns(bool){
        
        require(mediaRootMap[hash].originalAuthor != from); // this function is only to transfer ownership of duplicate copies, not original
        
        var copyNum = mediaRootMap[hash].copiesMap[from];
        //map the copynumber to buyer address
        mediaRootMap[hash].copiesMap[from] = copyNum;
        //assign 0 copynumber to the seller address
        mediaRootMap[hash].copiesMap[from] = 0;
        return true;
    }
    
    //makeDuplicate
    function _makeDuplicate(bytes32 hash, address buyer, bool sellable, uint price)internal mediaExists(hash) returns(bool){
        var root = mediaRootMap[hash];
        
        require(root.originalAuthor != buyer);
        require(root.soldCopies < root.maxAllowedCopies);
        
        root.soldCopies += 1;
        //map the copynumber to buyer address
        mediaRootMap[hash].copiesMap[buyer] = root.soldCopies;
        //create details of the coresponding copy
        var md = root.mediaDetailsMap[root.soldCopies];  
        md.isAvailable = true;
        md.isSellable = sellable;
        md.price = price;
        
        if(root.soldCopies == root.maxAllowedCopies){
            //assign 0 copynumber to the original author if all maximum allowed copies are sold
            mediaRootMap[hash].copiesMap[root.originalAuthor] = 0;
        }
        return true;
    }
    
    
    
    function buy(bytes32 hash, address from) public{
        _changeOwner(hash,from,msg.sender);
    }
    function duplicate(bytes32 hash, bool sellable, uint newPrice) public{
        _makeDuplicate(hash,msg.sender, sellable, newPrice);
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
        mapping (uint => uint) lastTxnId;                   //mapping of media copy number to last transaction number of that copy
        mapping (uint => transaction[]) mediaHistory;        // mapping media copy number to all transactions of a particular media
    }
    
    mapping (bytes32 => mediaTransaction ) allHistory;  //mapping to store all history of all media
    
    
    function buyMedia(bytes32 hash, address seller) public isAvailable(hash, seller) isSellable(hash, seller) userExists(msg.sender)
            payable returns(bool){
        
        uint sellPrice = getPriceOf(hash, seller);  //check if sent price is greater than the selling price
        require (msg.value >= sellPrice);
        
        seller.transfer(msg.value);             
        
        uint copynum = _getMediaCopyNumber(hash, seller);
        require( _changeOwner(hash, seller, msg.sender) );                      //change ownership of media
        _storeATransaction(hash, copynum, sellPrice, seller, msg.sender);          //record that transaction
        
        return true;
    }
    
    function _storeATransaction(bytes32 hash,uint copynum, uint price, address from, address to) internal returns(bool){
        mediaTransaction resource = allHistory[hash];                
        
        uint currentTxnId = resource.lastTxnId[copynum] + 1;
        resource.lastTxnId[copynum] = currentTxnId;
        
        transaction newTransaction = ( resource.mediaHistory[copynum] )[currentTxnId];    //create a new transaction
        newTransaction.transactionID = currentTxnId;
        newTransaction.price = price;
        newTransaction.from = from;
        newTransaction.to = to;
        newTransaction.datestamp = now;
        
        return true;
    }
    
    
    address[] allOwnersList;
    // get all previous owners of a media
    function getPreviousOwners(bytes32 hash, uint copynum)view  public mediaExists(hash) returns(address[]){
        var allOwners = allOwnersList;
        mediaTransaction media = allHistory[hash];
        
        //push the original author first
        allOwners.push(getOriginalOwnerOf(hash));
        
        //push the buyers of that media
        for (uint i=1; i<=media.lastTxnId[copynum]; i++){
            var t = ( media.mediaHistory[copynum] )[i];
            allOwners.push(t.from);
        }
        
        return allOwners;
    }
    
    //get all details of a particular transaction of a media
    function getDetailsOfTxnID(bytes32 hash, uint copynum, uint txnNo) public returns(uint price, address seller, address buyer){
        mediaTransaction asset = allHistory[hash];
        require (asset.lastTxnId[copynum] >= txnNo);             //make sure the transaction number is valid
        transaction txn = ( asset.mediaHistory[copynum] )[txnNo];
        return(txn.price, txn.from, txn.to);
    }
    
}


