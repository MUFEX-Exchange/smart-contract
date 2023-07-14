// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./IBaseTreasury.sol";

interface IMainTreasury is IBaseTreasury {
    event VerifierSet(address verifier);
    event ZKPUpdated(uint64 zkpId, address[] tokens, uint256[] balanceRoots, uint256[] withdrawRoots, uint256[] totalBalances, uint256[] totalWithdraws);
    event GeneralWithdrawn(address token, address indexed account, address indexed to, uint64 zkpId, uint256 index, uint256 amount, uint256 withdrawId);
    event ForceWithdrawn(address token, address indexed account, uint64 zkpId, uint256 index, uint256 amount);
    
    function ETH() external view returns (address);
    function verifier() external view returns (address);
    function withdrawTreasury() external view returns (address);
    function zkpId() external view returns (uint64);
    function getBalanceRoot(address token) external view returns (uint256);
    function getWithdrawRoot(address token) external view returns (uint256);
    function getTotalBalance(address token) external view returns (uint256);
    function getTotalWithdraw(address token) external view returns (uint256);
    function getWithdrawn(address token) external view returns (uint256);
    function getWithdrawFinished(address token) external view returns (bool);
    function lastUpdateTime() external view returns (uint256);
    function forceTimeWindow() external view returns (uint256);
    function forceWithdrawOpened() external view returns (bool);
    function firstUpdated(address token) external view returns (bool);

    function setVerifier(address verifier_) external;
    function setWithdrawTreasury(address withdrawTreasury_) external;

    function updateZKP(
        uint64 newZkpId,
        address[] calldata tokens,
        uint256[] calldata newBalanceRoots,
        uint256[] calldata newWithdrawRoots,
        uint256[] calldata newTotalBalances,
        uint256[] calldata newTotalWithdraws
    ) external;

    struct GeneralWithdrawParams {
        uint256[] proof;
        uint256 index;
        uint256 withdrawId;
        uint256 accountId;
        uint256 amount;
        address account;
        address to;
        address token;
        uint8 withdrawType;
        // just for signature
        uint256 fee;
        string chainName;
        string tokenName;
        string expiresAt;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function generalWithdraw(GeneralWithdrawParams calldata params) external;

    function forceWithdraw(
        uint256[] calldata proof,
        uint256 index,
        uint256 accountId,
        uint256 equity,
        address token
    ) external;
}