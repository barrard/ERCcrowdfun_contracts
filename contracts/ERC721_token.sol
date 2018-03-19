
pragma solidity ^0.4.18;
import "./ERC721CrowdSale.sol";
// contract Ownable {
//   address public owner;
//   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
//   /**
//   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
//   * account.
//   */
//   function Ownable() public {
//     owner = msg.sender;
//   }

//   /**
//   * @dev Throws if called by any account other than the owner.
//   */
//   modifier onlyOwner() {
//     require(msg.sender == owner);
//     _;
//   }

//   /**
//   * @dev Allows the current owner to transfer control of the contract to a newOwner.
//   * @param newOwner The address to transfer ownership to.
//   */
//   function transferOwnership(address newOwner) public onlyOwner {
//     require(newOwner != address(0));
//     OwnershipTransferred(owner, newOwner);
//     owner = newOwner;
//   }

// }

/**
 * Interface for required functionality in the ERC721 standard
 * for non-fungible tokens.
 *
 * Author: Nadav Hollander (nadav at dharma.io)
 */
// contract ERC721 {
//     // Function
//     function totalSupply() public view returns (uint256 _totalSupply);
//     function balanceOf(address _owner) public view returns (uint256 _balance);
//     function ownerOf(uint _tokenId) public view returns (address _owner);
//     function approve(address _to, uint _tokenId) public;
//     function getApproved(uint _tokenId) public view returns (address _approved);
//     function transferFrom(address _from, address _to, uint _tokenId) public;
//     function transfer(address _to, uint _tokenId) public;
//     function implementsERC721() public view returns (bool _implementsERC721);

//     // Events
//     event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
//     event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
// }

/**
 * Interface for optional functionality in the ERC721 standard
 * for non-fungible tokens.
 *
 * Author: Nadav Hollander (nadav at dharma.io)
 */
// contract DetailedERC721 is ERC721 {
//     function name() public view returns (string _name);
//     function symbol() public view returns (string _symbol);
//     function tokenMetadata(uint _tokenId) public view returns (string _infoUrl);
//     function tokenOfOwnerByIndex(address _owner, uint _index) public view returns (uint _tokenId);
// }


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

    uint public numTokensTotal;

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
    
    MintableNonFungibleToken _token_address = this;
    uint public token_counter = 0;
    uint public prop_token_counter = 0;
    uint[] private total_prop_tokens;
    uint[] private spent_prop_tokens;

    uint public _crowdsale_counter = 0;
    CrowdSale[] public CrowdSales;
    
    mapping(address => uint[]) property_to_tokens;
    // mapping(uint => address) token_to_address;
    mapping(address=>CrowdSale) addres_to_Property;
    mapping(address=>uint)owner_to_crowdsale_to_token;
    mapping(uint=>address)crowdsale_token_to_address;
    // mapping(uint=>address)prop_tokens_crowdsale;

    
    struct CrowdSale{
        uint _id;
        address _address;
        bool _visible;
        string[] _pics;
        address _wallet_raising_funds;
        uint _token_id;
        
        }


    event Seed_Tokes_Minted(address _to, address _metadata ,uint256 _tokenId);
    event Crowdsale_initiated(address crowdsale, address indexed _from, uint256 indexed _tokenId);
    event Prop_token_minted(uint prop_token_counter, address  _buyer, address  _from, uint _token_id);
    // event CrowdsaleToken_Purchased(address indexed purchaser);

    modifier onlyNonexistentToken(uint _tokenId) {
        require(tokenIdToOwner[_tokenId] == address(0));
        _;
    }

    function get_total_prop_tokens() public returns (uint){
        return total_prop_tokens.length;
    }
    function get_spent_prop_tokens() public returns (uint){
        return spent_prop_tokens.length;
    }

    function get_tokens_for_property(address _property) public returns (uint[]){
        return property_to_tokens[_property];
    }

    function spend_CS_Token(uint _token_id) public {

        require(ownerOf(_token_id) == msg.sender);
        // require(this == get_where_tokens_belong(_token_id) ); 

        require (tokenIdToMetadata[_token_id] == address(this));
        approve(address(this), _token_id);
        this.transferFrom(msg.sender, address(this), _token_id);

        spent_prop_tokens.push(_token_id);
        address _new_crowdasle = make_new_property(msg.sender);
        emit Crowdsale_initiated(_new_crowdasle, msg.sender, _token_id);
    } 
    //43200, 1, "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "1000", "0x35ef07393b57464e93deb59175ff72e6499450cf", "1000"
    //time(min), rate, "wallet raising funds",              cap,       Token,                                        goal
    // function make_new_property(address _wallet) internal returns(uint _id, address _crowdsale, bool _visible, address _wallet_raising_funds){
    function make_new_property(address _wallet) internal returns(address _crowdsale){
      address _new_crowdsale = new ERC721CrowdSale(43200, 1, _wallet, 1000, _token_address, 1000);
      CrowdSale storage _new_crowdsale_obj = addres_to_Property[_new_crowdsale];
      _new_crowdsale_obj._id = _crowdsale_counter;
      _new_crowdsale_obj._address = _new_crowdsale;
      _new_crowdsale_obj._visible = true;
      _new_crowdsale_obj._token_id = _crowdsale_counter;
      _new_crowdsale_obj._wallet_raising_funds = _wallet;
      CrowdSales.push(_new_crowdsale_obj);
      _crowdsale_counter++;
      // return (_new_crowdsale_obj._id, _new_crowdsale_obj._address, _new_crowdsale_obj._visible, _new_crowdsale_obj._wallet_raising_funds);
      return (_new_crowdsale);

    }


    function () external payable {
      buyToken(msg.sender);
    }

    function buyToken(address _buyer) public payable {
      require(msg.value == 1 ether);
      // uint256 weiAmount = msg.value;
      // uint256 tokenAmount = weiAmount / (1 ether / 10);
      _preValidatePurchase(_buyer);

      // calculate token amount to be created
      // uint256 tokens = _getTokenAmount(tokenAmount);

      // update state
      // ethRaised = ethRaised.add(tokenAmount/10);

      _processPurchase(_buyer);


    //   _updatePurchasingState(_buyer, tokenAmount);

      // _forwardFunds();
      // _postValidatePurchase(_buyer, tokenAmount);
    }

    function _preValidatePurchase(address _buyer) pure internal{
      require(_buyer != address(0));
    }

    function _processPurchase(address _buyer) internal {
        mint_prop_token(this, this);
      _deliverTokens(_buyer);
    }

    function _deliverTokens(address _buyer) internal {
        uint _tokenID = this.get_one_OwnerToken_id(this);
        this.transfer(_buyer, _tokenID);
        crowdsale_token_to_address[_tokenID] = _buyer;
    }

    function _forwardFunds() internal {
      address(this).transfer(msg.value);
    }

    function get_crowdsale_count() public view returns(uint){
        return _crowdsale_counter;
    }

    function get_property_by_id(uint id) public view returns(uint _id, address _crowdsale, bool _visible, address _wallet_raising_funds){
        CrowdSale memory _crowdsale_obj = CrowdSales[id];
        return (_crowdsale_obj._id, _crowdsale_obj._address, _crowdsale_obj._visible, _crowdsale_obj._wallet_raising_funds);
    }
    
    // function get_where_tokens_belong(uint _tokenID) public view returns(address){
    //     return token_to_address[_tokenID];
        
    // }
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
    
    function mint_token_lot(uint _amount, address _addr, address _metadata) public{
        for (uint x = 0 ; x < _amount ; x++){
            mint(_addr, token_counter, _metadata);
            // token_to_address[token_counter] = _addr;
            property_to_tokens[_metadata].push(token_counter);
            token_counter++;
        }
        emit Seed_Tokes_Minted(_addr ,_metadata ,_amount);
    }    
    function mint_prop_token(address _addr, address _metadata) public{
        mint(_addr, token_counter, _metadata);
        // token_to_address[token_counter] = _addr;
        // property_to_tokens[_addr].push(token_counter);
        total_prop_tokens.push(prop_token_counter);
        emit Prop_token_minted(prop_token_counter, _addr, _metadata, token_counter);

        prop_token_counter++;
        token_counter++;

    }
}