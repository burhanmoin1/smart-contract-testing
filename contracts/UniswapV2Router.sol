// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract MyUniswapHelper {
    IUniswapV2Router02 public uniswapRouter;
    address public owner;
    address public token;

    constructor(address _token) {
        uniswapRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D // UniswapV2 Router address on Ethereum
        );
        token = _token;
        owner = msg.sender;
    }

    function addLiquidity(uint256 tokenAmount) external payable {
        IERC20(token).transferFrom(msg.sender, address(this), tokenAmount);
        IERC20(token).approve(address(uniswapRouter), tokenAmount);

        uniswapRouter.addLiquidityETH{ value: msg.value }(
            token,
            tokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp + 300
        );
    }

    function swapTokensForETH(uint256 tokenAmount) external {
        IERC20(token).transferFrom(msg.sender, address(this), tokenAmount);
        IERC20(token).approve(address(uniswapRouter), tokenAmount);

        address ;
        path[0] = token;
        path[1] = uniswapRouter.WETH();

        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            msg.sender,
            block.timestamp + 300
        );
    }

    receive() external payable {}
}
