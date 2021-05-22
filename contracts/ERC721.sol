pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./IERC721.sol";
import "./ERC165.sol";
import "./SafeMath.sol";


/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is ERC165,IERC721 {
    using SafeMath for uint256;
    
    
    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner, 
        address indexed approved, 
        uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

/*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    // /*
    //  *     bytes4(keccak256('name()')) == 0x06fdde03
    //  *     bytes4(keccak256('symbol()')) == 0x95d89b41
    //  *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
    //  *
    //  *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
    //  */
    // bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    // /*
    //  *     bytes4(keccak256('totalSupply()')) == 0x18160ddd
    //  *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) == 0x2f745c59
    //  *     bytes4(keccak256('tokenByIndex(uint256)')) == 0x4f6ccce7
    //  *
    //  *     => 0x18160ddd ^ 0x2f745c59 ^ 0x4f6ccce7 == 0x780e9d63
    //  */
    // bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    string public _name;

    // Token symbol
    string public _symbol;
    
    // Token Contract Owner
    address payable public _contractOwner;
    
    struct petObj {
        address owner;
        uint256 id;
        string uri;
        uint256 price_in_wei;
        string breed;
        string location;
        uint256 age;
    }

    //mapping (uint256 => petObj) public petObjArray;
    petObj[] public petObjArray1;
    
    constructor () public {
        _name = "waqas-petShop1";
        _symbol = "WPS";
        _contractOwner = msg.sender;
        
       

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }
    
    uint256 public tokenIdCounter = 0;
    
    
    
    uint _totalSupply;
   
    // Mapping from owner address to their set of owned tokens
    mapping (address => uint256[]) private _ownerTokens;
    

    //mapping for holding index of token in owner 
    mapping(address => mapping(uint256 => uint256)) public _ownerTokenIndex;
    

    // token mapping from token ids to their owners
    mapping(uint256 => address) public _tokenOwners;
    
    
    function _mint(string memory petUri, uint256 price, string memory breed, string memory location, uint256 age) public returns (petObj memory) {
       // require(msg.sender == _contractOwner, "This function is allowed for contract owner only");
        
        
        
        //require(!_exists(tokenId), "ERC721: token already minted");

        _totalSupply = _totalSupply.add(1);
        
                                                                                                                                        //state update on adding token
                                                                                                                                        // _addToken(to,tokenIdCounter);
        petObj memory tx1 = petObj(_contractOwner,tokenIdCounter,petUri,price, breed,location,age);
        petObjArray1.push(tx1);
        
        
        //assign owner to token
        _tokenOwners[tokenIdCounter] =  _contractOwner;
        
        //push new token into owner's posession
        _ownerTokens[_contractOwner].push(tokenIdCounter);
        
        //stored new index 
        uint256 newIndex = _ownerTokens[_contractOwner].length-1;
        _ownerTokenIndex[_contractOwner][tokenIdCounter]= newIndex;
        
        
        tokenIdCounter = tokenIdCounter.add(1);
        return tx1;
        
        
        
        
        emit Transfer(msg.sender, msg.sender, tokenIdCounter);
        
    }
    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external  view returns (uint256 balance){
        
        require(owner != address(0), "ERC721: balance query for the zero address");
        
        return _ownerTokens[owner].length;
    }
    function ownerOf(uint256 tokenId) public  view returns (address owner) {    
        address owner1 = _tokenOwners[tokenId];
        require(owner1 != address(0), "ERC721: owner query for nonexistent token");

        return owner1;
    }
    function _transfer(address to, uint256 tokenId) public  {
        require(tokenId > 0, "ERC721: Invalid tokenId - tokenId can't be 0");
        require(ownerOf(tokenId) == msg.sender, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

       

        //delete of from address;
        _deleteToken(msg.sender,tokenId);
        
        //adding new token
        _addToken(to,tokenId);
        
        emit Transfer(msg.sender, to, tokenId);
    }
    function _addToken(address transferror, uint tokenId) internal returns(bool success, uint256 newIndex){
        //token shouldn't be exist;
        // require(_exists(tokenId),"ERC721: Token does not exist");
        
        petObjArray1[tokenId].owner = transferror;
        //assign owner to token
        _tokenOwners[tokenId] =  transferror;
        
        //push new token into owner's posession
        _ownerTokens[transferror].push(tokenId);
        
        //stored new index 
        newIndex = _ownerTokens[transferror].length-1;
        _ownerTokenIndex[transferror][tokenId]= newIndex;
    
        success = true;
    }
    function _deleteToken(address from, uint tokenId) internal  returns(bool success, uint256 index){
        require(_exists(tokenId),"ERC721:Invalid Token - Token not exist");
        //require(_tokenOwners[tokenId] == from,"ERC721: Invalid ownership - Token is not owned by owner");
        
        index = _ownerTokenIndex[from][tokenId];
        
        
        //more than one token swap last entry to current index
        if(_ownerTokens[from].length>1){
            uint lastToken = _ownerTokens[from][_ownerTokens[from].length-1];   
            _ownerTokens[from][index] = lastToken;
            _ownerTokenIndex[from][lastToken] = index;
        }
        //remove last entry
        _ownerTokens[from].pop();
        //remove Index
        delete _ownerTokenIndex[from][tokenId];
        //remove owner
        delete _tokenOwners[tokenId];
        success = true;
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        
        address owner = _tokenOwners[tokenId];
        
        if(owner != address(0))
            return true;
        else
            return false;
    }
    
    
    function Buy(uint256 tokenID) public payable {
        require(_exists(tokenID),"token does not exist bhai");
        require(petObjArray1[tokenID].price_in_wei <= msg.value,"value must be higher then the price ");
        
        address transferror = petObjArray1[tokenID].owner;
        petObjArray1[tokenID].owner = msg.sender;
        
    
    //Addition 
        _ownerTokens[msg.sender].push(tokenID);
    
        uint256 newIndex = _ownerTokens[msg.sender].length-1;
        _ownerTokenIndex[msg.sender][tokenID]= newIndex;
        
        _tokenOwners[tokenID] = msg.sender;
        
        //mapping (address => uint256[]) private _ownerTokens;
        //mapping(address => mapping(uint256 => uint256)) public _ownerTokenIndex;
        //mapping(uint256 => address) internal _tokenOwners;
        
    //Deletion 
    
        uint256 index = _ownerTokenIndex[transferror][tokenID];
        
        if(_ownerTokens[transferror].length>1){
            uint lastToken = _ownerTokens[transferror][_ownerTokens[transferror].length-1];   
            _ownerTokens[transferror][index] = lastToken;
            _ownerTokenIndex[transferror][lastToken] = index;
        }
        _ownerTokens[transferror].pop();
        
        delete _ownerTokenIndex[transferror][tokenID];
        //remove owner
        //delete _tokenOwners[tokenID];
        
        
    //Transfer Funds
    
            address payable wallet = address(uint160(transferror));
            
            wallet.transfer(msg.value);
    
        
        
        
         
    }
    function transferFrom(address from, address to, uint256 tokenId)  external{
        
        address abc = address(0);
        }
    function approve(address to, uint256 tokenId)  external{ 
        
    }
    function getApproved(uint256 tokenId) external  view returns (address operator){ }
    function setApprovalForAll(address operator, bool _approved)  external{ }
    function isApprovedForAll(address owner, address operator) external   view returns (bool){
        return true;
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external  payable{}
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{}
    
    function getData () public  view returns (petObj[] memory){
    
    return petObjArray1;
        
    }
    
    function getBalance () public view returns (uint256){
        return address(this).balance;
    }
    
    
    
}



