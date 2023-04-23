// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

interface IDepositWalletFactory {
    event WalletCreated(bytes32 indexed salt, address indexed wallet);

    function treasury() external returns (address);

    function getWallet(bytes32 salt) external returns (address);

    function createWallet(bytes32 salt) external returns (address wallet);

    function batchCollectTokens(address[] memory wallets, address[] memory tokens) external;
}