// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

interface ITreasury {
    event OperatorChanged(address indexed oldOperator, address indexed newOperator);
    event EtherWithdraw(address recipient, uint256 amount);
    event TokenWithdrawn(address token, address recipient, uint256 amount);

    function operator() external view returns (address);

    function changeOperator(address newOperator) external;

    function withdrawETH(address recipient, uint256 amount) external;

    function batchWithdrawETH(address[] memory recipients, uint256[] memory amounts) external;

    function withdrawToken(address token, address recipient, uint256 amount) external;

    function withdrawTokenToRecipients(address token, address[] memory recipients, uint256[] memory amounts) external;

    function batchWithdrawTokensToRecipients(address[] memory tokens, address[] memory recipients, uint256[] memory amounts) external;
}