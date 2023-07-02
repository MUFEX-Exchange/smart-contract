// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

interface IBaseTreasury {
    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);
    event EthDeposited(address indexed sender, uint256 amount);
    event TokenDeposited(address indexed token, address indexed sender, uint256 amount);
    
    function isOperator(address) external view returns (bool);

    function addOperator(address operator) external;

    function removeOperator(address operator) external;

    function depositETH() external payable;

    function depositToken(address token, uint256 amount) external;
}