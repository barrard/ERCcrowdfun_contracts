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
  uint256 public rate;

  // Amount of eth raised
  uint256 public ethRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value eths paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * @param _rate Number of token units a buyer gets per eth
   * @param _token Address of the token being sold
   */
  function Crowdsale(uint256 _rate, address _wallet, DetailedERC721 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
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
    require(msg.value > 1 ether /10);
    uint256 weiAmount = msg.value;
    uint256 tokenAmount = weiAmount / (1 ether / 10);
    _preValidatePurchase(_beneficiary, tokenAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(tokenAmount);

    // update state
    ethRaised = ethRaised.add(tokenAmount/10);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(msg.sender, _beneficiary, tokenAmount, tokens);


    _updatePurchasingState(_beneficiary, tokenAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, tokenAmount);
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

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Value in eth involved in the purchase
   */
  function _postValidatePurchase(address _beneficiary, uint256 _tokenAmount) internal pure returns(address, uint256){
    return (_beneficiary, _tokenAmount);
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
    return _tokenAmount.mul(rate);
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

  /**
   * @dev Reverts if not in crowdsale time range. 
   */
  modifier onlyWhileOpen {
    require(now >= openingTime && now <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.

   */
//  @param _openingTime Crowdsale opening time
//  @param _closingTime Crowdsale closing time
  // function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
  function TimedCrowdsale(uint _crowdsale_length_minutes) public {
    // require(_openingTime >= now);
    // require(_closingTime >= _openingTime);
    require(_crowdsale_length_minutes > 0);

    openingTime = now;
    closingTime = now + (_crowdsale_length_minutes * 1 minutes);
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    return now > closingTime;
  }
  
  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Amount of eth contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _tokenAmount) view internal onlyWhileOpen{
    super._preValidatePurchase(_beneficiary, _tokenAmount);
  }

  function _postValidatePurchase(uint _goal, uint _raised) internal {
    if(_goal == _raised) closingTime = now;
    // super._postValidatePurchase();


  }

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
    require(ethRaised.add(_tokenAmount) <= cap);
  }

}


contract ERC721CrowdSale is CappedCrowdsale, RefundableCrowdsale {
// 43200, 1, "0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "1000", "0x35ef07393b57464e93deb59175ff72e6499450cf", "1000"
  // function ERC721CrowdSale(uint256 _openingTime, uint256 _closingTime, uint256 _rate, uint256 _cap, MintableToken _token, uint256 _goal) public
  function ERC721CrowdSale(uint256 _crowdsale_length_minutes, uint256 _rate, address _wallet, uint256 _cap, DetailedERC721 _token, uint256 _goal) public
  Crowdsale(_rate, _wallet, _token)
    CappedCrowdsale(_cap)
    // TimedCrowdsale(_openingTime, _closingTime)
    TimedCrowdsale(_crowdsale_length_minutes)
    RefundableCrowdsale(_goal)
  {
    //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds
    require(_goal <= _cap);

  }
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
    
    function End_crowd_sale () public onlyOwner returns(bool res) {
      if(ethRaised == goal) {
          closingTime = now;
        return true;
      }else{
        return false;

      }
    }

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