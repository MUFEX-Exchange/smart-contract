// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

interface IDepositWallet {
    event EtherCollected(address indexed treasury, uint256 amount);
    event TokenCollected(address indexed treasury, address indexed token, uint256 amount);

    function treasury() external view returns (address);

    function initialize(address treasury_) external;

    function collectETH() external;

    function collectTokens(address[] memory tokens) external;
}