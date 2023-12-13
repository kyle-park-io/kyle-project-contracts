// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// a library for performing various math operations

library Math {
  function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = x < y ? x : y;
  }

  // // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
  // function sqrt(uint256 y) internal pure returns (uint256 z) {
  //     if (y > 3) {
  //         z = y;
  //         uint256 x = y / 2 + 1;
  //         while (x < z) {
  //             z = x;
  //             x = (y / x + x) / 2;
  //         }
  //     } else if (y != 0) {
  //         z = 1;
  //     }
  // }

  function sqrt(uint256 x) internal pure returns (uint256) {
    if (x == 0) return 0;
    // this block is equivalent to r = uint256(1) << (BitMath.mostSignificantBit(x) / 2);
    // however that code costs significantly more gas
    uint256 xx = x;
    uint256 r = 1;
    if (xx >= 0x100000000000000000000000000000000) {
      xx >>= 128;
      r <<= 64;
    }
    if (xx >= 0x10000000000000000) {
      xx >>= 64;
      r <<= 32;
    }
    if (xx >= 0x100000000) {
      xx >>= 32;
      r <<= 16;
    }
    if (xx >= 0x10000) {
      xx >>= 16;
      r <<= 8;
    }
    if (xx >= 0x100) {
      xx >>= 8;
      r <<= 4;
    }
    if (xx >= 0x10) {
      xx >>= 4;
      r <<= 2;
    }
    if (xx >= 0x8) {
      r <<= 1;
    }
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1;
    r = (r + x / r) >> 1; // Seven iterations should be enough
    uint256 r1 = x / r;
    return (r < r1 ? r : r1);
  }
}
