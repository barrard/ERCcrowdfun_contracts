pragma solidity ^0.4.21;

import "./CappedCrowdsale.sol";
import "./RefundableCrowdsale.sol";


contract MVP2_crowdsale is RefundableCrowdsale{


  function MVP2_crowdsale(
    string _name,
    uint256 _rate, 
    address _wallet, 
    address _token_address,
    uint256 _total_tokens,
    uint256 _time_limit_seconds)
    Crowdsale(_rate, _wallet, _token_address)
    TimedCrowdsale(_time_limit_seconds)
    // TimedCrowdsale(_crowdsale_length_minutes, _goal)
    RefundableCrowdsale(_rate * _total_tokens)
  {
      //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds

    // owner = _wallet;

  }

}
