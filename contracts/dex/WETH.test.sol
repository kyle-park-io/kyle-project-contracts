// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './interfaces/IWETH.sol';

import 'hardhat/console.sol';

contract WETH_TEST is IWETH {
  uint256 public totalSupply;
  mapping(address => uint256) public balanceOf;
  event Transfer(address indexed from, address indexed to, uint256 value);

  function deposit() public payable {
    totalSupply += msg.value;
    balanceOf[msg.sender] += msg.value;

    console.log('deposit');
    console.log('Deposit from %s %s tokens', msg.sender, msg.value);
  }

  function transfer(address to, uint256 value) public returns (bool) {
    // TODO: fix logic
    require(balanceOf[msg.sender] >= value);
    balanceOf[msg.sender] -= value;
    balanceOf[to] += value;
    // emit Transfer(msg.sender, to, value);

    console.log('transfer');
    console.log('Transferring from %s to %s %s tokens', msg.sender, to, value);

    return true;
  }

  function withdraw(uint256 value) public {
    totalSupply -= value;
    // send eth to router contract
    (bool success, ) = msg.sender.call{value: value}(new bytes(0));
    require(success, 'withdraw: ETH transfer failed');
  }
}
