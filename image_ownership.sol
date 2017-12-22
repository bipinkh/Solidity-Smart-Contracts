pragma solidity ^0.4.0;

contract pixelMessage{
    
    //image and owner mapper
    mapping (bytes32 => address) image_owner;
    address contractOwner;
    
    
    //constructor to set contract owner
    function pixelMessage() public payable{
        contractOwner = msg.sender;
    }
    
    
    /* modifiers */
    
    //check if the image is owned by someone
    modifier isOwned(bytes32 identifier){
        require( image_owner[identifier] != 0x0 );
        _;
    }
     modifier isNotOwned(bytes32 identifier){
        require( image_owner[identifier] == 0x0 );
        _;
    }
    
    //check if the image belongs to the given user
    modifier legalOwner(bytes32 identifier, address user){
        require (image_owner[identifier] == user);
        _;
    }
    
    
    /* functions */ 
    
    //set a owner of new image
    function setOwner(bytes32 identifier, address owner ) public isNotOwned(identifier) returns (bool success){
        image_owner[identifier]=owner;
        return true;
    }
    
    //get the owner of image
    function getOwner(bytes32 identifier) public isOwned(identifier) constant returns (address owner){
         return image_owner[identifier];
    }
    
    //transfer ownership by the legal owner only
    function transfer(bytes32 identifier, address newOwner) public legalOwner(identifier, msg.sender) constant returns (bool success){
        image_owner[identifier]=newOwner;
        return true;
    }
    
    //delete image only by the legal owner
    function deleteImage(bytes32 identifier) public legalOwner(identifier, msg.sender) constant returns (bool success){
        image_owner[identifier] = 0x0;
        return true;
    }
    
}
