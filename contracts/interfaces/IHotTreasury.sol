// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./IBaseTreasury.sol";

interface IHotTreasury is IBaseTreasury {
    event EthWithdrawn(address indexed operator, address indexed recipient, uint256 amount, string requestId);
    event TokenWithdrawn(address indexed token, address indexed operator, address indexed recipient, uint256 amount, string requestId);

    function withdrawETH(address recipient, uint256 amount, string memory requestId) external;

    function withdrawToken(address token, address recipient, uint256 amount, string memory requestId) external;

    function batchWithdrawETH(address[] calldata recipients, uint256[] calldata amounts, string[] calldata requestIds) external;

    function batchWithdrawToken(address[] calldata tokens, address[] calldata recipients, uint256[] calldata amounts, string[] calldata requestIds) external;
}