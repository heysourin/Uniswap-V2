// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

interface IUniswapV2Router {
    function swapExactTokenForToken(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
