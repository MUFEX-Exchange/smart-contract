// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./ITreasury.sol";

interface IMainTreasury is ITreasury {
    event DepositETH(address indexed sender, uint256 amount);
    event DepositToken(address indexed token, address indexed sender, uint256 amount);

    function depositETH() external payable;
    function depositToken(address token, uint256 amount) external;
    function forceWithdrawETH(address recipient, uint256 amount) external;
    function forceWithdrawToken(address token, address recipient, uint256 amount) external;
}