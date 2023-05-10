// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./interfaces/IERC20.sol";
import "./interfaces/IDepositWallet.sol";
import "./libraries/TransferHelper.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract DepositWallet is IDepositWallet, Initializable {
    address public treasury;

    receive() external payable {
        TransferHelper.safeTransferETH(treasury, msg.value);
        emit EtherCollected(treasury, msg.value);
    }

    function initialize(address treasury_) external override initializer {
        treasury = treasury_;
    }

    function collectETH() external override {
        uint256 balance = address(this).balance;
        TransferHelper.safeTransferETH(treasury, balance);
        emit EtherCollected(treasury, balance);
    }

    function collectTokens(address[] memory tokens) external override {
        uint256 balance_;
        for (uint256 i = 0; i < tokens.length; i++) {
            balance_ = IERC20(tokens[i]).balanceOf(address(this));
            if (balance_ > 0) {
                TransferHelper.safeTransfer(tokens[i], treasury, balance_);
                emit TokenCollected(treasury, tokens[i], balance_);
            }
        }
    }
}