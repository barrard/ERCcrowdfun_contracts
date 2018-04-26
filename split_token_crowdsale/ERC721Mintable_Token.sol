
pragma solidity ^0.4.18;
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract ERC721CrowdSale  {
    function ERC721CrowdSale(string _name, uint256 _crowdsale_length_minutes, uint256 _price_per_token, address _wallet, uint256 _cap, DetailedERC721 _token, uint256 _goal, uint256 _token_goal) {}
    function transferOwnership(address newOwner) public {}
    function finalize() public {}
    function capReached() public view returns (bool) {}
    function goalReached() public view returns (bool) {}
    function claimRefund() public {}
    function hasClosed() public view returns (bool) {}
    bool public isFinalized;
    address public owner;
    address public vault;


    function () external payable {}

}

contract CS_Creator {
    function create_crowdsale(string _name, uint256 _crowdsale_length_minutes, uint256 _price_per_token, address _wallet, uint256 _cap, DetailedERC721 _token, uint256 _goal, uint256 _token_goal) returns(address){}
    address public owner;
}


/**
 * Interface for required functionality in the ERC721 standard
 * for non-fungible tokens.
 *
 * Author: Nadav Hollander (nadav at dharma.io)
 */
contract ERC721 {
    // Function
    function totalSupply() public view returns (uint256 _totalSupply);
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint _tokenId) public view returns (address _owner);
    function approve(address _to, uint _tokenId) public;
    function getApproved(uint _tokenId) public view returns (address _approved);
    function transferFrom(address _from, address _to, uint _tokenId) public;
    function transfer(address _to, uint _tokenId) public;
    function implementsERC721() public view returns (bool _implementsERC721);
    function get_one_OwnerToken_id (address _owner) public view returns(uint _tokenId);

    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}

/**
 * Interface for optional functionality in the ERC721 standard
 * for non-fungible tokens.
 *
 * Author: Nadav Hollander (nadav at dharma.io)
 */
contract DetailedERC721 is ERC721 {
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function tokenMetadata(uint _tokenId) public view returns (address _addr);
    function tokenOfOwnerByIndex(address _owner, uint _index) public view returns (uint _tokenId);
}


/**
 * @title NonFungibleToken
 *
 * Generic implementation for both required and optional functionality in
 * the ERC721 standard for non-fungible tokens.
 *
 * Heavily inspired by Decentraland's generic implementation:
 * https://github.com/decentraland/land/blob/master/contracts/BasicNFT.sol
 *
 * Standard Author: dete
 * Implementation Author: Nadav Hollander <nadav at dharma.io>
 */
contract NonFungibleToken is DetailedERC721, Ownable{
    string public name;
    string public symbol;

    uint numTokensTotal;

    mapping(uint => address) internal tokenIdToOwner;
    mapping(uint => address) internal tokenIdToApprovedAddress;
    mapping(uint => address) internal tokenIdToMetadata;
    mapping(address => uint[]) internal ownerToTokensOwned;
    mapping(uint => uint) internal tokenIdToOwnerArrayIndex;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _tokenId
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenId
    );

    modifier onlyExtantToken(uint _tokenId) {
        require(ownerOf(_tokenId) != address(0));
        _;
    }

    function name()
        public
        view
        returns (string _name)
    {
        return name;
    }

    function symbol()
        public
        view
        returns (string _symbol)
    {
        return symbol;
    }
    function set_symbol(string _symbol) public onlyOwner {
        symbol = _symbol;
    }

    function totalSupply()
        public
        view
        returns (uint256 _totalSupply)
    {
        return numTokensTotal;
    }

    function balanceOf(address _owner)
        public
        view
        returns (uint _balance)
    {
        return ownerToTokensOwned[_owner].length;
    }

    function ownerOf(uint _tokenId)
        public
        view
        returns (address _owner)
    {
        return _ownerOf(_tokenId);
    }

    function tokenMetadata(uint _tokenId)
        public
        view
        returns (address _address)
    {
        return tokenIdToMetadata[_tokenId];
    }

    function approve(address _to, uint _tokenId)
        public
        onlyExtantToken(_tokenId)
    {
        require(msg.sender == ownerOf(_tokenId));
        require(msg.sender != _to);

        if (_getApproved(_tokenId) != address(0) ||
                _to != address(0)) {
            _approve(_to, _tokenId);
            emit Approval(msg.sender, _to, _tokenId);
        }
    }

    function transferFrom(address _from, address _to, uint _tokenId)
        public
        onlyExtantToken(_tokenId)
    {
        require(getApproved(_tokenId) == msg.sender);
        require(ownerOf(_tokenId) == _from);
        require(_to != address(0));

        _clearApprovalAndTransfer(_from, _to, _tokenId);

        emit Approval(_from, 0, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint _tokenId)
        public
        onlyExtantToken(_tokenId)
    {
        require(ownerOf(_tokenId) == msg.sender);
        require(_to != address(0));

        _clearApprovalAndTransfer(msg.sender, _to, _tokenId);

        emit Approval(msg.sender, 0, _tokenId);
        emit Transfer(msg.sender, _to, _tokenId);
    }

    function tokenOfOwnerByIndex(address _owner, uint _index)
        public
        view
        returns (uint _tokenId)
    {
        return _getOwnerTokenByIndex(_owner, _index);
    }

    function getOwnerTokens(address _owner)
        public
        view
        returns (uint[] _tokenIds)
    {
        return _getOwnerTokens(_owner);
    }

    function get_my_tokens()
        public
        view
        returns (uint[] _tokenIds)
    {
        return _getOwnerTokens(msg.sender);
    }

    function get_one_OwnerToken_id(address _owner)
        public
        view
        returns (uint _tokenIds)
    {
        return _get_one_OwnerToken_id(_owner);
    }

    

    function implementsERC721()
        public
        view
        returns (bool _implementsERC721)
    {
        return true;
    }

    function getApproved(uint _tokenId)
        public
        view
        returns (address _approved)
    {
        return _getApproved(_tokenId);
    }

    function _clearApprovalAndTransfer(address _from, address _to, uint _tokenId)
        internal
    {
        _clearTokenApproval(_tokenId);
        _removeTokenFromOwnersList(_from, _tokenId);
        _setTokenOwner(_tokenId, _to);
        _addTokenToOwnersList(_to, _tokenId);
    }

    function _ownerOf(uint _tokenId)
        internal
        view
        returns (address _owner)
    {
        return tokenIdToOwner[_tokenId];
    }

    function _approve(address _to, uint _tokenId)
        internal
    {
        tokenIdToApprovedAddress[_tokenId] = _to;
    }

    function _getApproved(uint _tokenId)
        internal
        view
        returns (address _approved)
    {
        return tokenIdToApprovedAddress[_tokenId];
    }

    function _getOwnerTokens(address _owner)
        internal
        view
        returns (uint[] _tokens)
    {
        return ownerToTokensOwned[_owner];
    }

    function _get_one_OwnerToken_id(address _owner)
        internal
        view
        returns (uint _tokenID)
    {
        return ownerToTokensOwned[_owner][0];
    }

    function _getOwnerTokenByIndex(address _owner, uint _index)
        internal
        view
        returns (uint _tokens)
    {
        return ownerToTokensOwned[_owner][_index];
    }

    function _clearTokenApproval(uint _tokenId)
        internal
    {
        tokenIdToApprovedAddress[_tokenId] = address(0);
    }

    function _setTokenOwner(uint _tokenId, address _owner)
        internal
    {
        tokenIdToOwner[_tokenId] = _owner;
    }

    function _addTokenToOwnersList(address _owner, uint _tokenId)
        internal
    {
        ownerToTokensOwned[_owner].push(_tokenId);
        tokenIdToOwnerArrayIndex[_tokenId] =
            ownerToTokensOwned[_owner].length - 1;
    }

    function _removeTokenFromOwnersList(address _owner, uint _tokenId)
        internal
    {
        uint length = ownerToTokensOwned[_owner].length;
        uint index = tokenIdToOwnerArrayIndex[_tokenId];
        uint swapToken = ownerToTokensOwned[_owner][length - 1];

        ownerToTokensOwned[_owner][index] = swapToken;
        tokenIdToOwnerArrayIndex[swapToken] = index;

        delete ownerToTokensOwned[_owner][length - 1];
        ownerToTokensOwned[_owner].length--;
    }

    function _insertTokenMetadata(uint _tokenId, address _metadata)
        internal
    {
        tokenIdToMetadata[_tokenId] = _metadata;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title MintableNonFungibleToken
 *
 * Superset of the ERC721 standard that allows for the minting
 * of non-fungible tokens.
 */
contract MintableNonFungibleToken is NonFungibleToken{
    using SafeMath for uint;
    address Crowdsale_creator_address;
    CS_Creator _cs_creator;
    
    MintableNonFungibleToken _token_address = this;
    uint public token_counter = 0;
    uint public CS_token_counter = 0;
    uint[] public total_CS_tokens;
    uint[] public spent_CS_tokens;
    string public name;
    function MintableNonFungibleToken(){
        name= "HArd coded name";
        // _cs_creator = CS_Creator(Crowdsale_creator_address);
    }
    uint public _crowdsale_counter = 0;
    CrowdSale[] public CrowdSales;
    
    mapping(address => uint[]) crowdsale_to_tokens;
    mapping(address=>CrowdSale) addres_to_Crowdsale;
    // mapping(address=>string)address_to_username;
    
    struct CrowdSale{
        string _name;
        uint _cap;
        uint _token_goal;
        uint _goal;
        uint _price_per_token;
        uint _time_limit;
        uint _id;
        address _address;
        bool _visible;
        string[] _pics;
        address _wallet_raising_funds;
        uint _token_id;
        
        }


    event Seed_Tokes_Minted(address _metadata ,uint256 _amount);
    event Crowdsale_initiated(address crowdsale, address indexed _from, uint256 indexed _tokenId);
    event CS_token_minted(uint CS_token_counter, address  _buyer, address  _from, uint _token_id);

    modifier onlyNonexistentToken(uint _tokenId) {
        require(tokenIdToOwner[_tokenId] == address(0));
        _;
    }

    function get_crowdsale_creator_address() public returns (address){
        return Crowdsale_creator_address;
    }
    function set_crowdsale_creator_address(address _addr) public onlyOwner returns (address){
        Crowdsale_creator_address = _addr;
        _cs_creator = CS_Creator(Crowdsale_creator_address);
        return address(_cs_creator);




    }


    function get_total_CS_tokens() public view returns (uint){
        return total_CS_tokens.length;
    }
    function get_spent_CS_tokens() public view returns (uint){
        return spent_CS_tokens.length;
    }

    function get_tokens_for_Crowdsale(address _Crowdsale) public view returns (uint[]){
        return crowdsale_to_tokens[_Crowdsale];
    }//      (string _name, uint256 _crowdsale_length_minutes, uint256 _price_per_token, address _wallet, uint256 _cap, DetailedERC721 _token, uint256 _goal, uint256 _token_goal) public

//"name",15, "180000000000000000", "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "540000000000000000", "0x4e12e17f3b2ecec2e4ed4890383529b49c54c923", "540000000000000000", 3
//"name",15, "1000000000000000000", "0xca35b7d915458ef540ade6068dfe2f44e8fa733c","3000000000000000000", "0x4e12e17f3b2ecec2e4ed4890383529b49c54c923", "3000000000000000000", 3
 //"great CS name", 10,     "1000000000000000",     "3000000000000000",  "3000000000000000",  3,    0
 // "great CS name", 10, "1000000000000000000", "3000000000000000000","3000000000000000000", 3,    0
    function spend_CS_Token(string _name, uint _time_limit, uint _price_per_token, uint _cap, uint _goal, uint _token_goal, uint _token_id) public {

        require(ownerOf(_token_id) == msg.sender);

        require (tokenIdToMetadata[_token_id] == address(this));
        approve(address(this), _token_id);
        this.transferFrom(msg.sender, address(this), _token_id);

        spent_CS_tokens.push(_token_id);        //wallett, token_id, time_in_minutes, rate
        address _new_crowdsale = make_new_crowdsale(_name, _time_limit, _price_per_token, msg.sender, _cap, _goal, _token_goal, _token_id);
        emit Crowdsale_initiated(_new_crowdsale, msg.sender, _token_id);
    } 
    //43200, 1, "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "1000", "0x35ef07393b57464e93deb59175ff72e6499450cf", "1000"
    //time(min), rate, "wallet raising funds",              cap,       Token,                                        goal
    // function make_new_crowdsale(address _wallet) internal returns(uint _id, address _crowdsale, bool _visible, address _wallet_raising_funds){
    function make_new_crowdsale(string _name, uint _time_limit, uint _price_per_token, address _wallet, uint _cap, uint _goal, uint _token_goal, uint _token_id) internal returns(address){
      address _new_crowdsale = _cs_creator.create_crowdsale(_name, _time_limit, _price_per_token, _wallet, _cap, _token_address, _goal, _token_goal);
      CrowdSale storage _new_crowdsale_obj = addres_to_Crowdsale[_new_crowdsale];
      _new_crowdsale_obj._name = _name;
      _new_crowdsale_obj._id = _crowdsale_counter;
      _new_crowdsale_obj._address = _new_crowdsale;
      _new_crowdsale_obj._visible = true;
      _new_crowdsale_obj._cap = _cap;
      _new_crowdsale_obj._token_goal = _token_goal;
      _new_crowdsale_obj._goal = _goal;
      _new_crowdsale_obj._price_per_token = _price_per_token;
      _new_crowdsale_obj._time_limit = _time_limit;
      _new_crowdsale_obj._token_id = _token_id;
      _new_crowdsale_obj._wallet_raising_funds = _wallet;
      CrowdSales.push(_new_crowdsale_obj);
      _crowdsale_counter++;
      return (_new_crowdsale);

    }


    function () external payable {
      buyToken(msg.sender);
    }

    function buyToken(address _buyer) public payable {
      require(msg.value == 1 ether);

      _preValidatePurchase(_buyer);



      _processPurchase(_buyer);

    }

    function _preValidatePurchase(address _buyer) pure internal{
      require(_buyer != address(0));
    }

    function _processPurchase(address _buyer) internal {
        mint_CS_token(this, this, _buyer);
    }

    function _deliverTokens(address _buyer, uint _id) internal {
        // uint _tokenID = this.get_one_OwnerToken_id(this);
        uint _tokenID = _id;
        this.transfer(_buyer, _tokenID);
    }

    function _forwardFunds() internal {
      address(this).transfer(msg.value);
    }

    function get_crowdsale_count() public view returns(uint){
        return _crowdsale_counter;
    }
    
    function get_crowdsale_id_by_address(address _addr) public view returns (uint){
        CrowdSale memory  crowdsale = (addres_to_Crowdsale[_addr]);
        return crowdsale._id;

    }


    function get_crowdsale_by_id(uint id) public view returns(      string _name,
                                                                  uint _cap,
                                                                  uint _token_goal,
                                                                  uint _goal,
                                                                  uint _price_per_token,
                                                                  uint _time_limit,
                                                                  uint _id,
                                                                  address _address,
                                                                  bool _visible,
                                                                  address _wallet_raising_funds,
                                                                  uint _token_id
      ){
        CrowdSale memory _cs = CrowdSales[id];
        return (_cs._name, _cs._cap, _cs._token_goal, _cs._goal,
                         _cs._price_per_token, _cs._time_limit, _cs._id, _cs._address,
                          _cs._visible, _cs._wallet_raising_funds, _cs._token_id);
    }
    

    function get_wei_balance() public view returns(uint){
        return address(this).balance;
    }

    function mint(address _owner, uint256 _tokenId, address _metadata)
        internal 
        
        onlyNonexistentToken(_tokenId)
    {
        _setTokenOwner(_tokenId, _owner);
        _addTokenToOwnersList(_owner, _tokenId);
        _insertTokenMetadata(_tokenId,  _metadata);
        numTokensTotal = numTokensTotal.add(1);
        // emit Mint(_owner, _tokenId);
    }

      modifier onlySame(address _addr1, address _addr2) {
        require(_addr1 == _addr2);
        _;
      }

    
    function mint_token_lot(uint _amount, address _metadata) public
    // onlySame(_addr, _metadata)
    {

        // require(_addr == _metadata);
        
        CrowdSale storage  crowdsale= (addres_to_Crowdsale[_metadata]);
        address addr = crowdsale._wallet_raising_funds;
        require(addr == msg.sender);
        for (uint x = 0 ; x < _amount ; x++){
            mint(this, token_counter, _metadata);
            crowdsale_to_tokens[_metadata].push(token_counter);
            _deliverTokens(_metadata, token_counter);

            token_counter++;
        }
        emit Seed_Tokes_Minted(_metadata ,_amount);
    }    
    function mint_CS_token(address _addr, address _metadata, address _buyer) internal{
        mint(_addr, token_counter, _metadata);
        total_CS_tokens.push(CS_token_counter);
        _deliverTokens(_buyer, token_counter);
        emit CS_token_minted(CS_token_counter, _buyer, _metadata, token_counter);
        CS_token_counter++;
        token_counter++;
    }
    
    // function get_username(address _addr) public view returns(string){
    //     return address_to_username[_addr];
    // }
    
    // function set_username(string _name) public {
    //      address_to_username[msg.sender]  = _name;
    // }
    
    //TODO Remove this
    function request_finalization(address _addr) public{
        CrowdSale storage  crowdsale= (addres_to_Crowdsale[_addr]);
        address addr = crowdsale._wallet_raising_funds;
        require(addr == msg.sender);
        ERC721CrowdSale erc721crowdsale = ERC721CrowdSale(_addr);
        erc721crowdsale.finalize();
    }
    // function add_photo_to_photo_array( string _url, address _addr) public{
    //     CrowdSale storage  crowdsale= (addres_to_Crowdsale[_addr]);
    //     address addr = crowdsale._wallet_raising_funds;
    //     require(addr == msg.sender);
    //     ERC721CrowdSale erc721crowdsale = ERC721CrowdSale(_addr);
    //     erc721crowdsale.add_photo_to_photo_array(_url);
    // }
}


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}