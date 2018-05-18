pragma solidity ^0.4.21;



import "./Ownable.sol";
import "./math/SafeMath.sol";
import "./Crowdsale/Crowdsale_creator.sol";
import "./ERC20/StandardToken.sol";



contract QAltify is Ownable{
  using SafeMath for uint256;

  uint public QAltFi_balance;
  uint public crowdsale_count;
  uint public price_to_start_crowdsale;
  address Crowdsale_creator_address;
  CS_Creator _cs_creator;

  
  //   MAPPING 
 
  // crowdsale address => token_address
  mapping(address=>address) public crowdsale_to_token;

  //  token_address => crowdsale address
  mapping(address=>address) public token_to_crowdsale;
  
  mapping(address=>bool) public crowdsale_map;

  
  
  //     STRUCT
  
  struct CrowdSale{
    string _name;
    uint _token_goal;
    uint _goal;
    uint _price_per_token;
    uint _opening_time;
    uint _closing_time;
    uint _id;
    address _token_address;
    address _crowdsale_address;
    bool _visible;
    address _wallet_raising_funds;
    uint _token_id;
		// uint last_traded_at;
		// uint number_of_trades;
		// uint[] voloume_last_10_trades;
		// uint[] tokens_for_sale;

  }

//          EVENTS
                                //wallett to forward funds  crowdsale_count    newly created address      newly creadted ERC20 token created
  event Crowdsale_started(address indexed purchaser, uint crowdsale_id, address crowdsale_address, address token_address);



  // function QAltify(string _name, string _symbol) public 
  function QAltify() public{
    QAltFi_balance = 0;
    crowdsale_count = 0;
    price_to_start_crowdsale = 1 ether;
  }

	function make_new_standard_token(
		string _name, 					//detailed
		string _symbol, 				//detailed
		uint256 _total_supply			//basic token
		) internal returns (address)
		// DetailedERC20(_name, _symbol)
		// BasicToken(_total_supply)
		{
		address new_standard_token = new StandardToken(_name, _symbol, _total_supply);
// 		address new_standard_token = new StandardToken("Dave", "rave", 111);
// 		StandardTokens_array.push(new_standard_token);
		return new_standard_token;
	}



    address[] public crowdsale_address_list;
	address[] public token_address_list;


//   function make_simple_crowdsale(uint256 _rate) public returns (address){
//     Crowdsale _cs;
//     StandardToken _st;
//     address _token_address = this.make_new_standard_token("Daves token", "$", 111);
//     _st = StandardToken(_token_address);
    
//     _cs = new Crowdsale(_rate, msg.sender, address(_token_address));
//     _st.transfer(_cs, 111);
//     crowdsales.push(address(_cs));
//     return address(_cs);
//   }  
                // "The Crowdslae Name", "The Symbolic Symobolism", 1, "100000000000000000000"
    function make_tokenized_crowdsale(string _name, string _symbol, uint256 _rate, uint256 _total_tokens, uint256 _time_limit_seconds) public returns (address){
        // Crowdsale _cs;
        // StandardToken _st;
        
        address _token_address = make_new_standard_token(_name, _symbol, _total_tokens);
// function make_detailed_crowdsale(string _name, address _wallet, string _symbol, uint256 _rate, address _token_address, uint256 _total, uint256 _time_limit_seconds) public returns (address){
        address _crowdsale_address = _cs_creator.make_detailed_crowdsale( _name, msg.sender,  _symbol,  _rate, _token_address, _total_tokens, _time_limit_seconds);
                
        // Crowdsale _cs;
        Token _st;
        _st = Token(_token_address);
        _st.transfer(_crowdsale_address, _total_tokens);
        
        crowdsale_map[_crowdsale_address] = true;
        crowdsale_address_list.push(_crowdsale_address);
        token_address_list.push(_token_address);
        crowdsale_to_token[_crowdsale_address] = _token_address;
        token_to_crowdsale[_token_address] = _crowdsale_address;
        
        
        


    
    //     address _token_address = make_new_standard_token(_name, _symbol, _total);

    // address _token_address = make_new_standard_token(_name, _symbol, _total);
    
    // _st = StandardToken(_token_address);
    
    // _cs = new Crowdsale(_rate, msg.sender, address(_token_address));
    // _st.transfer(_cs, _total);
    // crowdsales.push(address(_cs));
    // return address(_cs);
  }  
  
  
  
  
  
  
     
//   function make_new_crowdsale(
//     string _name, 
//     uint _opening_time,
//     uint _closing_time,
//     uint _price_per_token, 
//     address _wallet,
//     uint _goal,
//     uint _token_goal) public payable returns(address){

//     StandardToken _st;
//     Crowdsale_Prototype_version _cspv;

//     address _token_address = this.make_new_standard_token("Daves token", "$", 100000000000000000000);

//     address _new_crowdsale = _cs_creator.create_crowdsale(_name, _opening_time, _closing_time, _price_per_token, _wallet, _token_address, _goal, _token_goal);
//     // address _new_crowdsale = _cs_creator.create_crowdsale("Dave", 1526257922, 1526357922, 10, 0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 111, _token_address, 111, 111);
//     CrowdSale memory _new_crowdsale_obj = crowdsales_array[crowdsale_count];
//     _new_crowdsale_obj._name = _name;
//     _new_crowdsale_obj._id = crowdsale_count;
//     _new_crowdsale_obj._crowdsale_address = _new_crowdsale;
//     _new_crowdsale_obj._visible = true;
//     _new_crowdsale_obj._token_goal = _token_goal;
//     _new_crowdsale_obj._goal = _goal;
//     _new_crowdsale_obj._price_per_token = _price_per_token;
//     _new_crowdsale_obj._opening_time = _opening_time;
//     _new_crowdsale_obj._closing_time = _closing_time;
//     _new_crowdsale_obj._token_address = _token_address;
//     _new_crowdsale_obj._wallet_raising_funds = _wallet;
//     // _new_crowdsale_obj.last_traded_at = 500;              //setting the initial price of each token
//     // _new_crowdsale_obj.number_of_trades = 0;              //thinking something live how many times tokens have been bought/sold
//     // _new_crowdsale_obj.voloume_last_10_trades = new uint[](10);   //keep record of last 10 trades?? just an idea
//     // _new_crowdsale_obj.tokens_for_sale = new uint[](1000);   //place to list tokens for sale?
//     _cspv = Crowdsale_Prototype_version(_new_crowdsale);
//     _st = StandardToken(_token_address);
//     _st.transfer(_cspv, 111);

//     crowdsales.push(_cspv);

//     crowdsales_array.push(_new_crowdsale_obj);
//     crowdsale_count++;
//     return (_new_crowdsale);

//   }

  	function get_crowdsale_creator_address() public view returns (address){
		return Crowdsale_creator_address;
	}
	function set_crowdsale_creator_address(address _addr) public onlyOwner returns (address){
		Crowdsale_creator_address = _addr;
		_cs_creator = CS_Creator(Crowdsale_creator_address);
		return address(_cs_creator);

	}
      
 
  // function get_qalt_bal() public returns (uint){
  //   return QAltFi_balance;
  // }

  
//   function () external payable {
//      create_crowdsale();

//   }
	
  function create_crowdsale(uint _goal) public payable {
    // uint256 weiAmount = msg.value;
    uint256 weiAmount = msg.value;
    address buyer = msg.sender;
    uint goal = _goal;

    _preValidatePurchase(buyer, weiAmount, goal);

    // calculate token amount to be created
    // uint256 tokens = _getTokenAmount(weiAmount);



    _processPurchase(buyer, weiAmount);
    // crowdsale_to_token
    // token_to_crowdsale                           //TODO
    //crete a crowdsale with its own token
    
    
    emit Crowdsale_started(
      buyer,                            //wallett to transfer fund
      crowdsale_count,                  //crowdsale_id
      this,                             //placeholder for the crowdsale_contact address
      this                              //place holder for the ERC20 token address
    );
    
    
                //DO I NEED THESE ???

    // _updatePurchasingState(buyer, weiAmount);

    // _forwardFunds();
    // _postValidatePurchase(buyer, weiAmount);
  }

	

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _buyer Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(address _buyer, uint256 _weiAmount, uint _goal) view internal {
    require (_goal != 0);
    require(_weiAmount == price_to_start_crowdsale);
    require(_buyer != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _buyer Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(address _buyer, uint256 _weiAmount) pure internal returns(address, uint256){
    return (_buyer, _weiAmount);
  }



  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _buyer Address receiving the tokens
   */
  function _processPurchase(address _buyer, uint _weiAmount) internal returns(address){
        // update state
    uint amount = _weiAmount;
    QAltFi_balance = QAltFi_balance.add(amount);
    // super._mint(_buyer, _token_id);
    // _deliverToken(_buyer, _token_id);
    crowdsale_count++;
    return _buyer;

  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _buyer Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(address _buyer, uint256 _weiAmount) internal pure returns (address, uint256){
    // optional override
    return(_buyer, _weiAmount);
  }



	
	
}









