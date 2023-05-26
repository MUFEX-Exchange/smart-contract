// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./BaseTreasury.sol";
import "./interfaces/IMainTreasury.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/MerkleProof.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract MainTreasury is IMainTreasury, BaseTreasury, Initializable {
    address public override verifier;

    bytes32 public override zkpId;
    bytes32 public override balanceRoot;
    bytes32 public override withdrawRoot;

    uint256 public override totalBalance;
    uint256 public override totalWithdraw;
    uint256 public override withdrawn;
    uint256 public override lastUpdateTime;
    uint256 public override forceTimeWindow;

    bool public override withdrawFinished;
    bool public override forceWithdrawOpened;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private generalWithdrawnBitMap;
    mapping(uint256 => uint256) private forceWithdrawnBitMap;
    uint256[] private allGeneralWithdrawnIndex;
    uint256[] private allForceWithdrawnIndex;

    function initialize(
        address token_,
        address verifier_,
        uint256 forceTimeWindow_
    ) external initializer {
        token = token_;
        verifier = verifier_;
        forceTimeWindow = forceTimeWindow_;
    }

    function updateZKP(
        bytes32 newZkpId,
        bytes32 newBalanceRoot,
        bytes32 newWithdrawRoot,
        uint256 newTotalBalance,
        uint256 newTotalWithdraw
    ) external override {
        require(msg.sender == verifier, "forbidden");
        require(!forceWithdrawOpened, "force withdraw opened");
        require(withdrawFinished, "last withdraw not finish yet");
        
        uint256 balanceOfThis = IERC20(token).balanceOf(address(this));
        require(balanceOfThis >= newTotalBalance + newTotalWithdraw, "not enough balance");
        require(newZkpId > zkpId, "old zkp");

        zkpId = newZkpId;
        balanceRoot = newBalanceRoot;
        withdrawRoot = newWithdrawRoot;
        totalBalance = newTotalBalance;
        totalWithdraw = newTotalWithdraw;
        withdrawFinished = false;
        lastUpdateTime = block.timestamp;

        // clear claimed records
        for (uint256 i = 0; i < allGeneralWithdrawnIndex.length; i++) {
            delete generalWithdrawnBitMap[allGeneralWithdrawnIndex[i]];
        }
        delete allGeneralWithdrawnIndex;

        emit ZKPUpdated(zkpId, balanceRoot, withdrawRoot, totalBalance, totalWithdraw);
    }

    function generalWithdraw(
        bytes32[] calldata proof,
        uint256 index,
        uint256 withdrawId,
        uint256 accountId,
        address account,
        address to,
        uint8 withdrawType,
        uint256 amount
    ) external override {
        require(!isWithdrawn(index, true), "Drop already withdrawn");
        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(zkpId, index, withdrawId, accountId, account, to, withdrawType, amount));
        require(MerkleProof.verify(proof, withdrawRoot, node), "Invalid proof");
        // Mark it withdrawn and send the token.
        _setWithdrawn(index, true);
        TransferHelper.safeTransfer(token, to, amount);

        withdrawn += amount;
        require(withdrawn <= totalWithdraw, "over totalWithdraw");
        if (withdrawn == totalWithdraw) withdrawFinished = true;

        emit GeneralWithdrawn(account, to, zkpId, index, amount);
    }

    function forceWithdraw(
        bytes32[] calldata proof,
        uint256 index,
        uint256 accountId,
        uint256 amount
    ) external override {
        require(block.timestamp > lastUpdateTime + forceTimeWindow, "not over forceTimeWindow");
        require(!isWithdrawn(index, false), "Drop already withdrawn");
        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(zkpId, index, accountId, msg.sender, amount));
        require(MerkleProof.verify(proof, balanceRoot, node), "Invalid proof");
        // Mark it withdrawn and send the token.
        _setWithdrawn(index, false);
        TransferHelper.safeTransfer(token, msg.sender, amount);

        if (!forceWithdrawOpened) forceWithdrawOpened = true;
        emit ForceWithdrawn(msg.sender, zkpId, index, amount); 
    }

    function isWithdrawn(uint256 index, bool isGeneral) public view returns (bool) {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        uint256 word;
        if (isGeneral) {
            word = generalWithdrawnBitMap[wordIndex];
        } else {
            word = forceWithdrawnBitMap[wordIndex];
        }
        uint256 mask = (1 << bitIndex);
        return word & mask == mask;
    }

    function _setWithdrawn(uint256 index, bool isGeneral) internal {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        if (isGeneral) {
            generalWithdrawnBitMap[wordIndex] = generalWithdrawnBitMap[wordIndex] | (1 << bitIndex);
            allGeneralWithdrawnIndex.push(wordIndex);
        } else {
            forceWithdrawnBitMap[wordIndex] = forceWithdrawnBitMap[wordIndex] | (1 << bitIndex);
            allForceWithdrawnIndex.push(wordIndex);
        }
    }
}