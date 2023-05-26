// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./ITreasury.sol";

interface IMainTreasury is ITreasury {
    event ZKPUpdated(bytes32 zkpId, bytes32 balanceRoot, bytes32 withdrawRoot, uint256 totalBalance, uint256 totalWithdraw);
    event GeneralWithdrawn(address indexed account, address indexed to, bytes32 zkpId, uint256 index, uint256 amount);
    event ForceWithdrawn(address indexed account, bytes32 zkpId, uint256 index, uint256 amount);

    function verifier() external view returns (address);
    function zkpId() external view returns (bytes32);
    // total balance merkle tree root, use for forceWithdraw
    function balanceRoot() external view returns (bytes32);
    // total withdraw merkle tree root, use for generalWithdraw
    function withdrawRoot() external view returns (bytes32);
    function totalBalance() external view returns (uint256);
    function totalWithdraw() external view returns (uint256);
    function withdrawn() external view returns (uint256);
    function lastUpdateTime() external view returns (uint256);
    function forceTimeWindow() external view returns (uint256);
    function withdrawFinished() external view returns (bool);
    function forceWithdrawOpened() external view returns (bool);

    function updateZKP(
        bytes32 newZkpId,
        bytes32 newBalanceRoot, 
        bytes32 newWithdrawRoot, 
        uint256 newTotalBalance, 
        uint256 newTotalWithdraw
    ) external;

    function generalWithdraw(
        bytes32[] calldata proof,
        uint256 index,
        uint256 withdrawId,
        uint256 accountId,
        address account,
        address to,
        uint8 withdrawType,
        uint256 amount
    ) external;

    function forceWithdraw(
        bytes32[] calldata proof,
        uint256 index,
        uint256 accountId,
        uint256 equity
    ) external;
}