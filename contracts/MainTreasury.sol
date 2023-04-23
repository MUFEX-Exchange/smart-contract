// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./interfaces/IMainTreasury.sol";
import "./Treasury.sol";
import "./libraries/TransferHelper.sol";

contract MainTreasury is IMainTreasury, Treasury {

    receive() external payable {}

    constructor(address operator_) Treasury(operator_) {}

    function depositETH() external payable override {
        require(msg.value > 0, "deposit amount is zero");
        emit DepositETH(msg.sender, msg.value);
    }

    function depositToken(
        address token,
        uint256 amount
    ) external override {
        require(token != address(0), "token is zero address");
        require(amount > 0, "deposit amount is zero");
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        emit DepositToken(token, msg.sender, amount);
    }

    function forceWithdrawETH(
        address recipient,
        uint256 amount
    ) external override {}

    function forceWithdrawToken(
        address token,
        address recipient,
        uint256 amount
    ) external override {}
}