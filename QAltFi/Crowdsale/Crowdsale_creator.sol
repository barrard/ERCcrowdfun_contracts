pragma solidity ^0.4.21;

import "../Ownable.sol";
import "./MVP2_crowdsale.sol";

/**
 * The CS_Creator contract creates a Crowdsale with the provided address as the mintable token
 */
contract CS_Creator is Ownable{
  mapping(uint=>address) public id_to_address;
  mapping(address=>address)crowdsale_to_owner;
  MVP2_crowdsale _cs;
  uint CS_counter=0;
  function CS_Creator () {
    // CS_Creator csc = CS_Creator(address(this));
    // csc.transferOwnership(_token);
  }

function make_detailed_crowdsale(string _name, address _wallet, string _symbol, uint256 _rate, address _token_address, uint256 _total_tokens, uint256 _time_limit_seconds) public returns (address){

    
    // _st = Token(_token_address);
    
    // string _name,
    // uint256 _time_limit_seconds, 
    // uint256 _price_per_token, 
    // address _wallet, 
    // address _token_address, 
    address _cs = new MVP2_crowdsale(_name, _rate, _wallet, address(_token_address), _total_tokens, _time_limit_seconds);
    transfer_CS_ownership(_cs, _wallet);

    return address(_cs);
  }  
  
  

  // function create_crowdsale(
  //   string _name, 
  //   uint256 openingTime, 
  //   uint256 closingTime, 
  //   uint256 _price_per_token, 
  //   address _wallet, 
  //   address _token_address, 
  //   uint256 _goal, 
  //   uint256 _token_goal) onlyOwner returns(address){
  //     address _new_crowdsale = new Crowdsale_Prototype_version(
  //       _name, openingTime, closingTime, _price_per_token,  _wallet,  _token_address,  _goal,  _token_goal);
  //     id_to_address[CS_counter] = _new_crowdsale;
  //     crowdsale_to_owner[_new_crowdsale] = _wallet;
  //     CS_counter++;
  //   //   transfer_CS_ownership(address(_new_crowdsale), _wallet);
  //     return (_new_crowdsale);
  // }


  function transfer_CS_ownership (address _new_crowdsale, address _wallet)  internal {
     _cs = MVP2_crowdsale(_new_crowdsale);
    _cs.transferOwnership(_wallet);

    
  }
  

}
