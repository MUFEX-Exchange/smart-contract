// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./interfaces/IERC20.sol";
import "./interfaces/ITreasury.sol";
import "./libraries/TransferHelper.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Treasury is ITreasury, Ownable {
    address public operator;

    modifier onlyOperator() {
        require(msg.sender == operator, "only operator");
        _;
    }

    constructor(address operator_) {
        operator = operator_;
    }

    function changeOperator(address newOperator) external override onlyOwner {
        emit OperatorChanged(operator, newOperator);
        operator = newOperator;
    }

    function withdrawETH(address recipient, uint256 amount) external override onlyOperator {
        require(recipient != address(0), "zero address");
        require(amount > 0, "zero amount");
        require(address(this).balance >= amount);
        TransferHelper.safeTransferETH(recipient, amount);
        emit EtherWithdraw(recipient, amount);
    }

    function batchWithdrawETH(
        address[] memory recipients,
        uint256[] memory amounts
    ) external override onlyOperator {
        require(recipients.length == amounts.length, "length not same");
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "zero address");
            require(amounts[i] > 0, "zero amount");
            require(address(this).balance >= amounts[i]);
            TransferHelper.safeTransferETH(recipients[i], amounts[i]);
            emit EtherWithdraw(recipients[i], amounts[i]);
        }
    }

    function withdrawToken(
        address token,
        address recipient,
        uint256 amount
    ) external override onlyOperator {
        require(token != address(0), "token is zero address");
        require(recipient != address(0), "recipient is zero address");
        require(amount > 0, "zero amount");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance not enough");
        TransferHelper.safeTransfer(token, recipient, amount);
        emit TokenWithdrawn(token, recipient, amount);
    }

    function withdrawTokenToRecipients(
        address token,
        address[] memory recipients,
        uint256[] memory amounts
    ) external override onlyOperator {
        require(token != address(0), "token is zero address");
        require(recipients.length == amounts.length, "length not same");
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "recipient is zero address");
            require(amounts[i] > 0, "zero amount");
            require(IERC20(token).balanceOf(address(this)) >= amounts[i], "balance not enough");
            TransferHelper.safeTransfer(token, recipients[i], amounts[i]);
            emit TokenWithdrawn(token, recipients[i], amounts[i]);
        }
    }

    function batchWithdrawTokensToRecipients(
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts
    ) external override onlyOperator {
        require(tokens.length == recipients.length && recipients.length == amounts.length, "length not same");
        for (uint256 i = 0; i < recipients.length; i++) {
            require(tokens[i] != address(0), "token is zero address");
            require(recipients[i] != address(0), "recipient is zero address");
            require(amounts[i] > 0, "zero amount");
            require(IERC20(tokens[i]).balanceOf(address(this)) >= amounts[i], "balance not enough");
            TransferHelper.safeTransfer(tokens[i], recipients[i], amounts[i]);
            emit TokenWithdrawn(tokens[i], recipients[i], amounts[i]);
        }
    }
}