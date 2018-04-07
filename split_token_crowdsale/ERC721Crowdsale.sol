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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC721 {
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
    event Return_extra_wei(address investor, uint returned_wei_value);

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
    function tokenMetadata(uint _tokenId) public view returns (address _address);
    function tokenOfOwnerByIndex(address _owner, uint _index) public view returns (uint _tokenId);
}





contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  DetailedERC721 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per eth
  uint256 public price_per_token;

  // Amount of eth raised
  uint256 public ethRaised;

  //refund any left over eth after calulating tokens * per_token 
  // uint public refund_amount=0;

  //did the last purchase require a refund of extra wei sent? default false
  bool public was_refunded=false;


  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value eths paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * @param _price_per_token Number of token units a buyer gets per eth
   * @param _token Address of the token being sold
   */
  function Crowdsale(uint256 _price_per_token, address _wallet, DetailedERC721 _token) public {
    require(_price_per_token > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    price_per_token = _price_per_token;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {
    // require(msg.value == 1 ether /10);
    uint256 weiAmount = msg.value;
    uint256 tokenAmount = weiAmount / price_per_token;
    uint refund_amount = weiAmount.sub(tokenAmount.mul(price_per_token));

    _preValidatePurchase(_beneficiary, tokenAmount);


    // calculate token amount to be created
    // uint256 tokens = _getTokenAmount(tokenAmount);

    // update state
    ethRaised = ethRaised.add(tokenAmount.mul(price_per_token));

    _processPurchase(_beneficiary, tokenAmount);
    emit TokenPurchase(msg.sender, _beneficiary, msg.value, tokenAmount);


    _updatePurchasingState(_beneficiary, tokenAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, refund_amount);
    // _check_for_extra(_beneficiary, refund_amount);

  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statemens to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Value in eth involved in the purchase
   */
  function _preValidatePurchase(address _beneficiary, uint256 _tokenAmount) view internal{
    require(_beneficiary != address(0));
    require(_tokenAmount != 0);
  }

  function _check_for_extra (address _beneficiary, uint _refund_amount)  internal {
    was_refunded = false;

    // if (_refund_amount > 0){
     // msg.value -= _refund_amount;
    // return true;
    // }else{
      // return false;
    // }
    
  }
  


  function _postValidatePurchase(address _beneficiary, uint256 _refund_amount) internal {
    // return (_beneficiary, _refund_amount);
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    for (uint x = 0 ; x < _tokenAmount ; x++ ){
      uint _tokenID = token.get_one_OwnerToken_id(this);
      token.transfer(_beneficiary, _tokenID);
    }
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }


  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Value in eth involved in the purchase
   */
  function _updatePurchasingState(address _beneficiary, uint256 _tokenAmount) internal pure returns (address, uint256){
      return (_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _tokenAmount Value in eth to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _tokenAmount
   */
  function _getTokenAmount(uint256 _tokenAmount) internal view returns (uint256) {
    return _tokenAmount.mul(price_per_token);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}


contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;
  uint256 public goal;

  /**
   * @dev Reverts if not in crowdsale time range. 
   */
  modifier onlyWhileOpen {
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.

   */
//  @param _openingTime Crowdsale opening time
//  @param _closingTime Crowdsale closing time
  // function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
  function TimedCrowdsale(uint _crowdsale_length_minutes, uint _goal) public {
    // require(_openingTime >= block.timestamp);
    // require(_closingTime >= _openingTime);
    require(_crowdsale_length_minutes > 0);

    goal = _goal;


    openingTime = block.timestamp;
    closingTime = block.timestamp + (_crowdsale_length_minutes * 1 minutes);
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    return (block.timestamp >= closingTime || ethRaised >= goal);
  }
  function hasClosed1() public view returns (bool, uint, uint) {
    return (ethRaised >= goal, goal, ethRaised);
  }
  function hasClosed2() public view returns (bool) {
    return (block.timestamp >= closingTime);
  }
  function get_now() public returns (uint){
    return block.timestamp;
  }
  
  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Amount of eth contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _tokenAmount) view internal onlyWhileOpen{
    super._preValidatePurchase(_beneficiary, _tokenAmount);
  }

  // function _postValidatePurchase(uint _goal, uint _raised) internal {
  //   if(_goal == _raised) closingTime = block.timestamp;
  //   // super._postValidatePurchase();


  // }

}


contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal  {
  }
}


contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 tokenAmount);
  event Return_extra_wei(address investor, uint returned_wei_value, uint depositedValue);

  /**
   * @param _wallet Vault address
   */
  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  /**
   * @param investor Investor address
   */
  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
    address(wallet).transfer(address(this).balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  /**
   * @param investor Investor address
   */
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    emit Refunded(investor, depositedValue);
  }

  function _return_extra_wei(address investor, uint returned_value) public onlyOwner {
    uint256 depositedValue = deposited[investor];
    uint new_depositedValue = depositedValue.sub(returned_value);
    deposited[investor] = new_depositedValue;
    investor.transfer(returned_value);
    emit Return_extra_wei(investor, returned_value, new_depositedValue);


  }
}


contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in eths
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  /**
   * @dev Constructor, creates RefundVault. 
   * @param _goal Funding goal
   */
  function RefundableCrowdsale(uint256 _goal) public {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  /**
   * @dev Investors can claim refunds here if crowdsale is unsuccessful
   */
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  /**
   * @dev Checks whether funding goal was reached. 
   * @return Whether funding goal was reached
   */
  function goalReached() public view returns (bool) {
    return ethRaised >= goal;
  }


  /**
   * @dev vault finalization task, called when owner calls finalize()
   */
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  /**
   * @dev Overrides Crowdsale fund forwarding, sending funds to vault.
   */
  function _forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  /**
   * @dev Constructor, takes maximum amount of eth accepted in the crowdsale.
   * @param _cap Max amount of eth to be contributed
   */
  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Checks whether the cap has been reached. 
   * @return Whether the cap was reached
   */
  function capReached() public view returns (bool) {
    return ethRaised >= cap;
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Amount of eth contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _tokenAmount) view internal {
    super._preValidatePurchase(_beneficiary, _tokenAmount);
    require(ethRaised.add(_tokenAmount.mul(price_per_token)) <= cap);
  }

}


contract ERC721CrowdSale is CappedCrowdsale, RefundableCrowdsale {
  uint public token_goal;
  string public name;
  // address public owner;
  // string public description;

  //first MVP from February// 43200, 1, "0x038343bfaf1f35b01d91513c8472764d55474045", "1000", "0x409F8C0Bb2C9C278a51E9f0E0f38AD32F663415e", "1000"
  //updated version for LIVE MVP                                               180000000000000000
  // 150, "180000000000000000", "0x769387d444ff8a4059983186deadcd1ab8e99390", "18000000000000000000", "0x584560d1676995db4728cc7b1773cb4903ffeae1", "18000000000000000000", 100
  // 15, "180000000000000000", "0x769387d444ff8a4059983186deadcd1ab8e99390", "540000000000000000", "0x4e12e17f3b2ecec2e4ed4890383529b49c54c923", "540000000000000000", 3
  // copy for safe keeping 43200, "180000000000000000", "0x038343bfaf1f35b01d91513c8472764d55474045", "612000000000000000000", "0x41acb3dca09f738224adec8089845ed43276c55d", "612000000000000000000", 3400
    // function SampleCrowdsale(uint256 _openingTime, uint256 _closingTime, uint256 price_per_token, uint256 _cap, MintableToken _token, uint256 _goal) public

  function ERC721CrowdSale(string _name, uint256 _crowdsale_length_minutes, uint256 _price_per_token, address _wallet, uint256 _cap, DetailedERC721 _token, uint256 _goal, uint256 _token_goal) public
  Crowdsale(_price_per_token, _wallet, _token)
    CappedCrowdsale(_cap)
    // TimedCrowdsale(_openingTime, _closingTime)
    TimedCrowdsale(_crowdsale_length_minutes, _goal)
    RefundableCrowdsale(_goal)
  {
    //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds
    require(_goal <= _cap);
    token_goal = _token_goal;
    name = _name;
    // owner = _wallet;

  }
  function _postValidatePurchase (address _beneficiary, uint _refund_amount)  internal {

    if (_refund_amount > 0){
      vault._return_extra_wei(_beneficiary, _refund_amount);

    }
     // msg.value -= _refund_amount;

      // was_refunded = true;
    // }else{
    //   was_refunded = false;
    // }
    
  }
  

    // function set_crowdsale_name(string _new_name) onlyOwner{
    //   name = _new_name;
    // }
    // function set_crowdsale_description(string _new_description) onlyOwner{
    //   description = _new_description;
    // }
    // function _updatePurchasingState(address _beneficiary, uint256 _tokenAmount) internal view returns(address, uint256){
    //   if(_checkIfCrowdsaleGoalReached()){
    //     super._postValidatePurchase(ethRaised, goal);
    //   }
    //   return (_beneficiary, _tokenAmount);
    // }

    // function _checkIfCrowdsaleGoalReached () public returns(bool res) {
    //   if(ethRaised == goal) return true;
    //   return false;
    // }
    function get_one_OwnerToken_id () public view returns(uint _tokenID) {
      return token.get_one_OwnerToken_id(this);      
    }
    
    // function End_crowd_sale () public onlyOwner returns(bool res) {
    //   if(ethRaised == goal) {
    //       closingTime = block.timestamp;
    //     return true;
    //   }else{
    //     return false;

    //   }
    // }

}

/**
 * The CS_Creator contract creates a Crowdsale with the provided address as the mintable token
 */
contract CS_Creator is Ownable{
  mapping(uint=>address) public id_to_address;
  mapping(address=>address)crowdsale_to_owner;
  ERC721CrowdSale _cs;
  uint CS_counter=0;
  function CS_Creator (address _token) {
    // CS_Creator csc = CS_Creator(address(this));
    // csc.transferOwnership(_token);
  }
  function create_crowdsale(string _name, uint256 _crowdsale_length_minutes, uint256 _price_per_token, address _wallet, uint256 _cap, DetailedERC721 _token, uint256 _goal, uint256 _token_goal) onlyOwner returns(address){
      address _new_crowdsale = new ERC721CrowdSale(_name, _crowdsale_length_minutes, _price_per_token,  _wallet,  _cap,  _token,  _goal,  _token_goal);
      id_to_address[CS_counter] = _new_crowdsale;
      crowdsale_to_owner[_new_crowdsale] = _wallet;
      CS_counter++;
      // transfer_CS_ownership(address(_new_crowdsale), _wallet);
      return _new_crowdsale;
  }

  function request_ownership(address _crowdsale) public returns(bool){
    require(msg.sender == crowdsale_to_owner[_crowdsale]);
    _cs = ERC721CrowdSale(_crowdsale);
    _cs.transferOwnership(msg.sender);
  }

  // function transfer_CS_ownership (address _new_crowdsale, address _wallet)  internal {
  //    _cs = ERC721CrowdSale(_new_crowdsale);
  //   _cs.transferOwnership(_wallet);

    
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