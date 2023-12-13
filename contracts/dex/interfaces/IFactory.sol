// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFactory {
  // event
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  // create2
  function INIT_CODE_PAIR_HASH() external view returns (bytes32);

  // pair
  function getPair(
    address tokenA,
    address tokenB
  ) external view returns (address pair);

  function createPair(
    address tokenA,
    address tokenB
  ) external returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  // fee
  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}
