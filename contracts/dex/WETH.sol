// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './interfaces/IWETH.sol';

contract WETH is IWETH {
  uint256 public totalSupply;
  mapping(address => uint256) public balanceOf;

  function deposit() public payable {
    totalSupply += msg.value;
    balanceOf[msg.sender] += msg.value;
  }

  function transfer(address to, uint256 value) public returns (bool) {
    // TODO: fix logic
    require(balanceOf[msg.sender] >= value);
    balanceOf[msg.sender] -= value;
    balanceOf[to] += value;
    return true;
  }

  function withdraw(uint256 value) public {
    totalSupply -= value;
    // send eth to router contract
    (bool success, ) = msg.sender.call{value: value}(new bytes(0));
    require(success, 'withdraw: ETH transfer failed');
  }
}
