pragma solidity ^0.4.17;

contract pixel{
    
    struct details{                         //to store details of each copy
        uint price;
        bool sellable;
        bool deleted;
    }
    
    struct transactions{                    //to record transactions of each copy
        address seller;
        address buyer;
        uint price;
        uint datetime;
    }
    
    struct mediaRoot{
        uint maxCopy;
        uint soldCopies;
        mapping (uint => address[]) currentOwners;                 //copy number => owner addresses of that copy
        mapping (address => uint) UsrCpyMap;            //map user address to his/her copynumber of the media
        mapping (uint => details) CpyDtlMap;            //map copy number of the media and its details
        mapping (uint => transactions[]) CpyTxnMap;     //map copy number to its transactions history
    }
    
    mapping (bytes32 => mediaRoot) HashRootMap;
}

contract user{
    
    struct userDetail{
        string Name;
        string Country;
        string Website;
        uint totalMedias;                       //total number of media the user owns
        mapping (bytes32 => uint) indexMediaMap;//media hash to its index map
        bytes32[] mediaLists;
    }
    
    mapping(address => userDetail) UserDetailMap;

    //other business logics left to add
}


contract main is pixel,user{
    
    modifier isAvailable(address usr, bytes32 hash){
        var root = HashRootMap[hash];
        require( root.UsrCpyMap[usr] != 0 );
        require( root.CpyDtlMap[ root.UsrCpyMap[usr] ].deleted == false );
        _; 
    }
    
    modifier isSellable(address usr, bytes32 hash){
        var root = HashRootMap[hash];
        require( root.CpyDtlMap[ root.UsrCpyMap[usr] ].sellable == true );
        _;
    }
    
    modifier noExistingPixel(bytes32 hash){
        var root = HashRootMap[hash];
        require(root.maxCopy == 0);
        _;
    }
    
    function createPixel(uint price, bool sellable, uint maxCopyNum, bytes32 hash) noExistingPixel(hash) public{
        var root = HashRootMap[hash];
        root.maxCopy = maxCopyNum;
        root.UsrCpyMap[msg.sender] = root.maxCopy+1;                          //maxCopy+1 copynumber for originalCreator
        root.CpyDtlMap[ root.maxCopy+1 ] = details(price, sellable, false);
        root.currentOwners[0].push(msg.sender);                                 //index 0 is assigned for originalCreator
    } 
    
    function deleteMyCopy(bytes32 hash) public isAvailable(msg.sender, hash) returns(bool deleted){
        var root = HashRootMap[hash];
        root.CpyDtlMap[ root.UsrCpyMap[msg.sender] ].sellable = false;
        root.CpyDtlMap[ root.UsrCpyMap[msg.sender] ].deleted = true;
        root.currentOwners[ root.UsrCpyMap[msg.sender]].push(0x0);
        return true;
    }
    
    function getDetailsOfMedia(address usr, bytes32 hash) view public isAvailable(usr, hash) returns(uint copyNumber, uint price, bool sellable){
        var root = HashRootMap[hash];
        return(root.UsrCpyMap[usr], 
                root.CpyDtlMap[ root.UsrCpyMap[usr] ].price, 
                root.CpyDtlMap[ root.UsrCpyMap[usr] ].sellable );
    }
    
    function updateMyMediaCopyDetails(uint price, bool sellable, bytes32 hash) public  returns(bool updated){
        var root = HashRootMap[hash];
        require( root.UsrCpyMap[msg.sender] != 0 );
        root.CpyDtlMap[ root.UsrCpyMap[msg.sender] ] = details(price, sellable, false);
        return true;
    }
    
    function buyMedia(address seller, bytes32 hash) public payable isSellable(seller, hash) returns(bool success){
        var root = HashRootMap[hash];
        var buyer = msg.sender;
        var cost = root.CpyDtlMap[ root.UsrCpyMap[seller] ].price;
        var originalAuthorAddress = root.currentOwners[0][0];
        
        require(  cost <= msg.value ); //ensure buyer has enough value to buy
        seller.transfer(msg.value);
        
        if(seller == originalAuthorAddress && root.soldCopies <= root.maxCopy){     //duplicate the media
            root.soldCopies++;
            root.UsrCpyMap[buyer] = root.soldCopies;
            root.CpyDtlMap[ root.soldCopies ] = root.CpyDtlMap[ root.maxCopy+1 ];   //copy all initial details
            if(root.soldCopies == root.maxCopy ){
                root.UsrCpyMap[ originalAuthorAddress ]=0;
            }
        }else{                                                                      //transfer ownership
            root.UsrCpyMap[buyer] = root.UsrCpyMap[seller];              
            root.UsrCpyMap[seller] = 0;
        }
        
        root.CpyDtlMap[ root.UsrCpyMap[buyer]].sellable = false;                    // buyer may not be willing to resale
        root.currentOwners[ root.UsrCpyMap[buyer] ].push(buyer);
        root.CpyTxnMap[ root.UsrCpyMap[buyer] ].push( transactions(seller, buyer, cost, now) ); //record transaction
        return true;
    }
    
    address[] ownerlist;
    function getCurrentOwners(bytes32 hash) public returns(address[]){
        var root = HashRootMap[hash];
        delete ownerlist;
        var returnlist = ownerlist;
        
        if (root.soldCopies < root.maxCopy){ returnlist.push(root.currentOwners[0][0]); }  //push the name of original author too
        
        for(uint i=1; i<= root.soldCopies; i++){
            returnlist.push( root.currentOwners[i][ root.currentOwners[i].length - 1 ]);
        }
        return returnlist;
    }
    
    function getAllOwnersOf(uint copyNumber, bytes32 hash) public returns(address[]){
        var root = HashRootMap[hash];
        delete ownerlist;
        var returnlist = ownerlist;
        for(uint i=0; i< ( root.currentOwners[copyNumber].length); i++){
            returnlist.push( root.currentOwners[copyNumber][i]);
        }
        return returnlist;
    }
    
    function getTransactionHistory(bytes32 hash, uint copyNumber, uint transactionNumber) view public
        returns(address buyer, address seller, uint price, uint datetime){
            var root = HashRootMap[hash];
             var t = ( root.CpyTxnMap[copyNumber])[transactionNumber];
             return(t.buyer, t.seller, t.price, t.datetime);
        }
    
}


