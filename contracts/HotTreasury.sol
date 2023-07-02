// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./BaseTreasury.sol";
import "./interfaces/IHotTreasury.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract HotTreasury is IHotTreasury, BaseTreasury, Initializable {

    function initialize() external initializer {
        owner = msg.sender; 
    }

    function withdrawETH(address recipient, uint256 amount, string calldata requestId) external override onlyOperator {
        _withdrawETH(recipient, amount, requestId);
    }

    function withdrawToken(address token, address recipient, uint256 amount, string calldata requestId) external override onlyOperator {
        _withdrawToken(token, recipient, amount, requestId);
    }

    function batchWithdrawETH(
        address[] calldata recipients, 
        uint256[] calldata amounts, 
        string[] calldata requestIds
    ) external override onlyOperator {
        require(
            recipients.length == amounts.length && 
            recipients.length == requestIds.length, "length not the same");
        for (uint256 i = 0; i < recipients.length; i++) {
            _withdrawETH(recipients[i], amounts[i], requestIds[i]);
        }
    }

    function batchWithdrawToken(
        address[] calldata tokens,
        address[] calldata recipients,
        uint256[] calldata amounts,
        string[] calldata requestIds
    ) external override onlyOperator {
        require(
            tokens.length == recipients.length &&
            recipients.length == amounts.length && 
            recipients.length == requestIds.length, "length not the same");
        for (uint256 i = 0; i < recipients.length; i++) {
            _withdrawToken(tokens[i], recipients[i], amounts[i], requestIds[i]);
        }
    }

    function _withdrawETH(address recipient, uint256 amount, string calldata requestId) internal {
        require(recipient != address(0), "recipient is zero address");
        require(amount > 0, "zero amount");
        require(address(this).balance >= amount, "balance not enough");
        TransferHelper.safeTransferETH(recipient, amount);
        emit EthWithdrawn(msg.sender, recipient, amount, requestId);
    }

    function _withdrawToken(address token, address recipient, uint256 amount, string calldata requestId) internal {
        require(token != address(0), "token is zero address");
        require(recipient != address(0), "recipient is zero address");
        require(amount > 0, "zero amount");
        require(IERC20(token).balanceOf(address(this)) >= amount, "balance not enough");
        TransferHelper.safeTransfer(token, recipient, amount);
        emit TokenWithdrawn(token, msg.sender, recipient, amount, requestId);
    }
}