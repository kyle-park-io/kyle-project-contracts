// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './libraries/Library.sol';
import './libraries/TransferHelper.sol';
import './interfaces/IRouter.sol';
import './interfaces/IPair.sol';
import './interfaces/IFactory.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Router is IRouter {
  address public immutable factory;

  modifier ensure(uint256 deadline) {
    // require(deadline >= block.timestamp, "Router: EXPIRED");
    _;
  }

  constructor(address _factory) {
    factory = _factory;
  }

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    override
    ensure(deadline)
    returns (uint256 amountA, uint256 amountB, uint256 liquidity)
  {
    (amountA, amountB) = _addLiquidity(
      tokenA,
      tokenB,
      amountADesired,
      amountBDesired,
      amountAMin,
      amountBMin
    );

    address pair = Library.pairFor(factory, tokenA, tokenB);
    // you should check approval (msg.sender -> router)
    TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
    TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
    // default: to == msg.sender
    liquidity = IPair(pair).mint(to);
  }

  // **** ADD LIQUIDITY ****
  function _addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin
  ) private returns (uint256 amountA, uint256 amountB) {
    // create the pair if it doesn't exist yet
    if (IFactory(factory).getPair(tokenA, tokenB) == address(0)) {
      IFactory(factory).createPair(tokenA, tokenB);
    }

    (uint256 reserveA, uint256 reserveB) = Library.getReserves(
      factory,
      tokenA,
      tokenB
    );
    if (reserveA == 0 && reserveB == 0) {
      (amountA, amountB) = (amountADesired, amountBDesired);
    } else {
      uint256 amountBOptimal = Library.quote(
        amountADesired,
        reserveA,
        reserveB
      );
      if (amountBOptimal <= amountBDesired) {
        require(amountBOptimal >= amountBMin, 'Router: INSUFFICIENT_B_AMOUNT');
        (amountA, amountB) = (amountADesired, amountBOptimal);
      } else {
        uint256 amountAOptimal = Library.quote(
          amountBDesired,
          reserveB,
          reserveA
        );
        assert(amountAOptimal <= amountADesired);
        require(amountAOptimal >= amountAMin, 'Router: INSUFFICIENT_A_AMOUNT');
        (amountA, amountB) = (amountAOptimal, amountBDesired);
      }
    }
  }
}
