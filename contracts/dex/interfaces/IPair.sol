// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPair {
  // event
  event Sync(uint112 reserve0, uint112 reserve1);
  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint amount0,
    uint amount1,
    address indexed to
  );

  // initialize
  function initialize(address, address) external;

  // reserve
  function getReserves()
    external
    view
    returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

  // add
  function mint(address to) external returns (uint256 liquidity);

  // remove
  function burn(address to) external returns (uint256 amount0, uint256 amount1);
}
