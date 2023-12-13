// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './interfaces/IPair.sol';

contract Pair is IPair {
  address public factory;

  address public token0;
  address public token1;

  constructor() {
    factory = msg.sender;
  }

  // called once by the factory at time of deployment
  function initialize(address _token0, address _token1) external {
    require(msg.sender == factory, 'Error: FORBIDDEN'); // sufficient check
    token0 = _token0;
    token1 = _token1;
  }
}
