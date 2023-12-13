// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '../Pair.sol';

contract DexCalc {
  // returns sorted token addresses, used to handle return values from pairs sorted in this order
  function sortTokens(
    address tokenA,
    address tokenB
  ) internal pure returns (address token0, address token1) {
    require(tokenA != tokenB, 'KyleDex: IDENTICAL_ADDRESSES');
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), 'KyleDex: ZERO_ADDRESS');
  }

  // calculates the CREATE2 address for a pair without making any external calls
  function pairFor(
    address factory,
    address tokenA,
    address tokenB
  ) internal pure returns (address pair) {
    (address token0, address token1) = sortTokens(tokenA, tokenB);
    pair = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex'ff',
              factory,
              keccak256(abi.encodePacked(token0, token1)),
              keccak256(abi.encodePacked(type(Pair).creationCode))
            )
          )
        )
      )
    );
  }

  function calcPair(
    address factory,
    address tokenA,
    address tokenB
  ) public pure returns (address) {
    address pair = pairFor(factory, tokenA, tokenB);
    return pair;
  }
}
