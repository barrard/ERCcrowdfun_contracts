pragma solidity ^0.4.21;

import "../math/SafeMath.sol";
import "./Crowdsale.sol";


/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _time_limit Crowdsale lengtho of time of crowdsale in seconds, minimum 1 week ~600000 seconds
   */
  function TimedCrowdsale(uint256 _time_limit) public {
    require(_time_limit >= 600000);

    openingTime = block.timestamp;
    closingTime = openingTime+_time_limit;
  }

  function get_opening_time() public view returns (uint256){
    return openingTime;      
  }
  function get_closing_time() public view returns (uint256){
    return closingTime;      
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

  function end_time_limit() internal {
      closingTime = block.timestamp;
  }

}
