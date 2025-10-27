// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract AggreagatorV3 is AggregatorV3Interface {
     int256 public answer;
    
  
    constructor(int256 _answer) {
        answer = _answer;
    }

    function setPrice(int256 _answer) public {
        answer = _answer;
    }

  function decimals() external view returns (uint8){
    return 1;
  }

  function description() external view override returns (string memory){
    return "Hello";
  }

  function version() external view override returns (uint256) {
    return 888;
  }

  function getRoundData(
    uint80 _roundId
  ) external view override returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound){
    return (_roundId, 1000000000000000000, 0, 0, 0);
  }



   

  function latestRoundData()
    external
    view override
    returns (uint80 roundId, int256 _answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound){
      return (1, answer, 0, 0, 0);
  }
   
}