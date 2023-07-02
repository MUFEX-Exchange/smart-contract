// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./interfaces/IERC20.sol";
import "./interfaces/IBaseTreasury.sol";
import "./libraries/TransferHelper.sol";
import "./Ownable.sol";

abstract contract BaseTreasury is IBaseTreasury, Ownable {
    mapping(address => bool) public override isOperator;

    modifier onlyOperator() {
        require(isOperator[msg.sender], "only operator");
        _;
    }

    receive() external payable {}

    function addOperator(address operator) external override onlyOwner {
        require(!isOperator[operator], "already added");
        isOperator[operator] = true;
        emit OperatorAdded(operator);
    }

    function removeOperator(address operator) external override onlyOwner {
        require(isOperator[operator], "operator not found");
        isOperator[operator] = false;
        emit OperatorRemoved(operator);
    }

    function depositETH() external payable virtual override {
        require(msg.value > 0, "deposit amount is zero");
        emit EthDeposited(msg.sender, msg.value);
    }

    function depositToken(address token, uint256 amount) external virtual override {
        require(token != address(0), "zero address");
        require(amount > 0, "deposit amount is zero");
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        emit TokenDeposited(token, msg.sender, amount);
    }
}