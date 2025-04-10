// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './interfaces/IPair.sol';
import './KyleERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract Pair is IPair, KyleERC20 {
  using UQ112x112 for uint224;

  // transfer signature
  bytes4 private constant SELECTOR =
    bytes4(keccak256(bytes('transfer(address,uint256)')));

  // control initial liquitidy
  uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;

  // address
  address public factory;
  address public token0;
  address public token1;

  // reserve
  uint112 private reserve0; // uses single storage slot, accessible via getReserves
  uint112 private reserve1; // uses single storage slot, accessible via getReserves
  uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

  // cumulation
  uint256 public price0CumulativeLast;
  uint256 public price1CumulativeLast;

  constructor() {
    factory = msg.sender;
  }

  uint256 private unlocked = 1;
  modifier lock() {
    require(unlocked == 1, 'Error: LOCKED');
    unlocked = 0;
    _;
    unlocked = 1;
  }

  function getReserves()
    public
    view
    returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast)
  {
    _reserve0 = reserve0;
    _reserve1 = reserve1;
    _blockTimestampLast = blockTimestampLast;
  }

  function _safeTransfer(address token, address to, uint256 value) private {
    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(SELECTOR, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'Error: TRANSFER_FAILED'
    );
  }

  // called once by the factory at time of deployment
  function initialize(address _token0, address _token1) external {
    require(msg.sender == factory, 'Error: FORBIDDEN'); // sufficient check
    token0 = _token0;
    token1 = _token1;
  }

  // update reserves and, on the first call per block, price accumulators
  function _update(
    uint256 balance0,
    uint256 balance1,
    uint112 _reserve0,
    uint112 _reserve1
  ) private {
    // require(
    //   balance0 <= uint112(-1) && balance1 <= uint112(-1),
    //   'Error: OVERFLOW'
    // );
    uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
    uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
    if (
      timeElapsed > uint32(0) &&
      _reserve0 != uint112(0) &&
      _reserve1 != uint112(0)
    ) {
      // * never overflows, and + overflow is desired
      price0CumulativeLast +=
        uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
        timeElapsed;
      price1CumulativeLast +=
        uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
        timeElapsed;
    }
    reserve0 = uint112(balance0);
    reserve1 = uint112(balance1);
    blockTimestampLast = blockTimestamp;
    emit Sync(reserve0, reserve1);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function mint(address to) external lock returns (uint256 liquidity) {
    (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings

    uint256 balance0 = IERC20(token0).balanceOf(address(this));
    uint256 balance1 = IERC20(token1).balanceOf(address(this));
    uint256 amount0 = balance0 - _reserve0;
    uint256 amount1 = balance1 - _reserve1;

    // bool feeOn = _mintFee(_reserve0, _reserve1);
    uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee

    if (_totalSupply == 0) {
      // TODO: check unchecked function
      liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
      _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
    } else {
      liquidity = Math.min(
        (amount0 * _totalSupply) / _reserve0,
        (amount1 * _totalSupply) / _reserve1
      );
    }
    require(liquidity > 0, 'Wrong: INSUFFICIENT_LIQUIDITY_MINTED');
    _mint(to, liquidity);

    _update(balance0, balance1, _reserve0, _reserve1);
    // if (feeOn) kLast = uint256(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
    emit Mint(msg.sender, amount0, amount1);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function burn(
    address to
  ) external lock returns (uint256 amount0, uint256 amount1) {
    (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
    address _token0 = token0; // gas savings
    address _token1 = token1; // gas savings
    uint256 balance0 = IERC20(_token0).balanceOf(address(this));
    uint256 balance1 = IERC20(_token1).balanceOf(address(this));
    uint256 liquidity = balanceOf[address(this)];

    // bool feeOn = _mintFee(_reserve0, _reserve1);
    uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
    amount0 = (liquidity * balance0) / _totalSupply; // using balances ensures pro-rata distribution
    amount1 = (liquidity * balance1) / _totalSupply; // using balances ensures pro-rata distribution
    require(
      amount0 > 0 && amount1 > 0,
      'KYLE_DEX: INSUFFICIENT_LIQUIDITY_BURNED'
    );
    _burn(address(this), liquidity);
    _safeTransfer(_token0, to, amount0);
    _safeTransfer(_token1, to, amount1);
    balance0 = IERC20(_token0).balanceOf(address(this));
    balance1 = IERC20(_token1).balanceOf(address(this));

    _update(balance0, balance1, _reserve0, _reserve1);
    // if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
    emit Burn(msg.sender, amount0, amount1, to);
  }

  // this low-level function should be called from a contract which performs important safety checks
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external lock {
    require(
      amount0Out > 0 || amount1Out > 0,
      'Error: INSUFFICIENT_OUTPUT_AMOUNT'
    );
    (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings

    require(
      amount0Out < _reserve0 && amount1Out < _reserve1,
      'Error: INSUFFICIENT_LIQUIDITY'
    );

    uint256 balance0;
    uint256 balance1;
    {
      // scope for _token{0,1}, avoids stack too deep errors
      address _token0 = token0;
      address _token1 = token1;
      require(to != _token0 && to != _token1, 'Error: INVALID_TO');
      if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
      if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
      // if (data.length > 0)
      //     ICallee(to).pancakeCall(
      //         msg.sender,
      //         amount0Out,
      //         amount1Out,
      //         data
      //     );
      balance0 = IERC20(_token0).balanceOf(address(this));
      balance1 = IERC20(_token1).balanceOf(address(this));
    }

    uint256 amount0In = balance0 > _reserve0 - amount0Out
      ? balance0 - (_reserve0 - amount0Out)
      : 0;
    uint256 amount1In = balance1 > _reserve1 - amount1Out
      ? balance1 - (_reserve1 - amount1Out)
      : 0;
    require(amount0In > 0 || amount1In > 0, 'Error: INSUFFICIENT_INPUT_AMOUNT');

    // {
    //     // scope for reserve{0,1}Adjusted, avoids stack too deep errors
    //     uint256 balance0Adjusted = (
    //         balance0.mul(10000).sub(amount0In.mul(25))
    //     );
    //     uint256 balance1Adjusted = (
    //         balance1.mul(10000).sub(amount1In.mul(25))
    //     );
    //     require(
    //         balance0Adjusted.mul(balance1Adjusted) >=
    //             uint(_reserve0).mul(_reserve1).mul(10000 ** 2),
    //         "Error: K"
    //     );
    // }

    _update(balance0, balance1, _reserve0, _reserve1);
    emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
  }
}
