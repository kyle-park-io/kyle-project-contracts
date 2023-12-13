// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Token is ERC20 {
  /*
   *  Constructor
   */
  constructor(
    string memory name_,
    string memory symbol_,
    uint256 totalSupply_
  ) ERC20(name_, symbol_) {
    _mint(msg.sender, totalSupply_);
  }
}
