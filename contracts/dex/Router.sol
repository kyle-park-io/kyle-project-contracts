// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './libraries/Library.sol';
import './libraries/TransferHelper.sol';
import './interfaces/IRouter.sol';
import './interfaces/IPair.sol';
import './interfaces/IFactory.sol';
import './interfaces/IWETH.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Router is IRouter {
  address public immutable factory;
  address public immutable WETH;

  modifier ensure(uint256 deadline) {
    // require(deadline >= block.timestamp, "Router: EXPIRED");
    _;
  }

  // TODO: set logic to receive, fallback function
  receive() external payable {}

  fallback() external payable {}

  constructor(address _factory, address _WETH) {
    factory = _factory;
    WETH = _WETH;
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

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    override
    ensure(deadline)
    returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
  {
    (amountToken, amountETH) = _addLiquidity(
      token,
      WETH,
      amountTokenDesired,
      msg.value,
      amountTokenMin,
      amountETHMin
    );
    address pair = Library.pairFor(factory, token, WETH);
    TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
    IWETH(WETH).deposit{value: amountETH}();
    assert(IWETH(WETH).transfer(pair, amountETH));
    // default: to = msg.sender
    liquidity = IPair(pair).mint(to);
    if (msg.value > amountETH)
      TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); // refund dust eth, if any
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

  // **** REMOVE LIQUIDITY ****
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    public
    override
    ensure(deadline)
    returns (uint256 amountA, uint256 amountB)
  {
    address pair = Library.pairFor(factory, tokenA, tokenB);
    Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
    (uint256 amount0, uint256 amount1) = IPair(pair).burn(to);
    (address token0, ) = Library.sortTokens(tokenA, tokenB);
    (amountA, amountB) = tokenA == token0
      ? (amount0, amount1)
      : (amount1, amount0);
    require(amountA >= amountAMin, 'Router: INSUFFICIENT_A_AMOUNT');
    require(amountB >= amountBMin, 'Router: INSUFFICIENT_B_AMOUNT');
  }

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    public
    override
    ensure(deadline)
    returns (uint256 amountToken, uint256 amountETH)
  {
    (amountToken, amountETH) = removeLiquidity(
      token,
      WETH,
      liquidity,
      amountTokenMin,
      amountETHMin,
      address(this),
      deadline
    );
    // TODO: check logic
    TransferHelper.safeTransfer(token, to, amountToken);
    IWETH(WETH).withdraw(amountETH);
    TransferHelper.safeTransferETH(to, amountETH);
  }

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint[] memory amounts) {
    amounts = Library.getAmountsOut(factory, amountIn, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      'Router: INSUFFICIENT_OUTPUT_AMOUNT'
    );
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      Library.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, to);
  }

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint[] memory amounts) {
    amounts = Library.getAmountsIn(factory, amountOut, path);
    require(amounts[0] <= amountInMax, 'Router: EXCESSIVE_INPUT_AMOUNT');
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      Library.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, to);
  }

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint[] memory amounts) {
    require(path[path.length - 1] == WETH, 'Router: INVALID_PATH');
    amounts = Library.getAmountsOut(factory, amountIn, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      'Router: INSUFFICIENT_OUTPUT_AMOUNT'
    );
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      Library.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, address(this));
    IWETH(WETH).withdraw(amounts[amounts.length - 1]);
    TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
  }

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint[] memory amounts) {
    require(path[path.length - 1] == WETH, 'Router: INVALID_PATH');
    amounts = Library.getAmountsIn(factory, amountOut, path);
    require(amounts[0] <= amountInMax, 'Router: EXCESSIVE_INPUT_AMOUNT');
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      Library.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, address(this));
    IWETH(WETH).withdraw(amounts[amounts.length - 1]);
    TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
  }

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable override ensure(deadline) returns (uint[] memory amounts) {
    require(path[0] == WETH, 'Router: INVALID_PATH');
    amounts = Library.getAmountsOut(factory, msg.value, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      'Router: INSUFFICIENT_OUTPUT_AMOUNT'
    );
    IWETH(WETH).deposit{value: amounts[0]}();
    assert(
      IWETH(WETH).transfer(
        Library.pairFor(factory, path[0], path[1]),
        amounts[0]
      )
    );
    _swap(amounts, path, to);
  }

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable override ensure(deadline) returns (uint[] memory amounts) {
    require(path[0] == WETH, 'Router: INVALID_PATH');
    amounts = Library.getAmountsIn(factory, amountOut, path);
    require(amounts[0] <= msg.value, 'Router: EXCESSIVE_INPUT_AMOUNT');
    IWETH(WETH).deposit{value: amounts[0]}();
    assert(
      IWETH(WETH).transfer(
        Library.pairFor(factory, path[0], path[1]),
        amounts[0]
      )
    );
    _swap(amounts, path, to);
    if (msg.value > amounts[0])
      TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]); // refund dust eth, if any
  }

  // **** SWAP ****
  // requires the initial amount to have already been sent to the first pair
  function _swap(
    uint[] memory amounts,
    address[] memory path,
    address _to
  ) private {
    for (uint256 i; i < path.length - 1; i++) {
      (address input, address output) = (path[i], path[i + 1]);
      (address token0, ) = Library.sortTokens(input, output);
      uint256 amountOut = amounts[i + 1];
      (uint256 amount0Out, uint256 amount1Out) = input == token0
        ? (uint256(0), amountOut)
        : (amountOut, uint256(0));
      address to = i < path.length - 2
        ? Library.pairFor(factory, output, path[i + 2])
        : _to;
      IPair(Library.pairFor(factory, input, output)).swap(
        amount0Out,
        amount1Out,
        to,
        new bytes(0)
      );
    }
  }
}
