// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./BaseTreasury.sol";
import "./interfaces/IMainTreasury.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/MerkleProof.sol";
import "./libraries/MiMC.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MainTreasury is IMainTreasury, BaseTreasury, Initializable {
    using ECDSA for bytes32;

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public override verifier;
    address public override withdrawTreasury;
    uint64 public override zkpId;

    mapping(address => uint256) public override getBalanceRoot;
    mapping(address => uint256) public override getWithdrawRoot;
    mapping(address => uint256) public override getTotalBalance;
    mapping(address => uint256) public override getTotalWithdraw;
    mapping(address => uint256) public override getWithdrawn;
    mapping(address => bool) public override getWithdrawFinished;
    
    uint256 public override lastUpdateTime;
    uint256 public override forceTimeWindow;

    bool public override forceWithdrawOpened;

    struct WithdrawnInfo {
        mapping(uint256 => uint256) generalWithdrawnBitMap;
        mapping(uint256 => uint256) forceWithdrawnBitMap;
        uint256[] allGeneralWithdrawnIndex;
        uint256[] allForceWithdrawnIndex;
    }
    mapping(address => WithdrawnInfo) private getWithdrawnInfo;

    modifier onlyVerifierSet {
        require(verifier != address(0), "verifier not set");
        _;
    }

    function initialize(uint256 forceTimeWindow_) external initializer {
        owner = msg.sender;
        forceTimeWindow = forceTimeWindow_;
    }

    function setVerifier(address verifier_) external override onlyOwner {
        require(verifier == address(0), "verifier already set");
        verifier = verifier_;
        emit VerifierSet(verifier_);
    }

    function setWithdrawTreasury(address withdrawTreasury_) external override onlyOwner {
        require(withdrawTreasury_ != address(0), "zero address");
        withdrawTreasury = withdrawTreasury_;
    }

    function updateZKP(
        uint64 newZkpId,
        address[] calldata tokens,
        uint256[] calldata newBalanceRoots,
        uint256[] calldata newWithdrawRoots,
        uint256[] calldata newTotalBalances,
        uint256[] calldata newTotalWithdraws
    ) external override onlyVerifierSet {
        require(msg.sender == verifier, "forbidden");
        require(!forceWithdrawOpened, "force withdraw opened");
        require(
            tokens.length == newBalanceRoots.length &&
            newBalanceRoots.length == newWithdrawRoots.length &&
            newWithdrawRoots.length == newTotalBalances.length &&
            newTotalBalances.length == newTotalWithdraws.length,
            "length not the same"
        );

        uint256 balanceOfThis;
        address token;
        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength; i++) {
            token = tokens[i];
            require(getWithdrawFinished[token], "last withdraw not finish yet");
            getWithdrawFinished[token] = false;

            if (token == ETH) {
                balanceOfThis = address(this).balance;
            } else {
                balanceOfThis = IERC20(token).balanceOf(address(this));
            }
            require(balanceOfThis >= newTotalBalances[i] + newTotalWithdraws[i], "not enough balance");
            
            getBalanceRoot[token] = newBalanceRoots[i];
            getWithdrawRoot[token] = newWithdrawRoots[i];
            getTotalBalance[token] = newTotalBalances[i];
            getTotalWithdraw[token] = newTotalWithdraws[i];

            WithdrawnInfo storage withdrawnInfo = getWithdrawnInfo[token];
            // clear claimed records
            uint256 length = withdrawnInfo.allGeneralWithdrawnIndex.length;
            for (uint256 j = 0; j < length; j++) {
                delete withdrawnInfo.generalWithdrawnBitMap[withdrawnInfo.allGeneralWithdrawnIndex[j]];
            }
            delete withdrawnInfo.allGeneralWithdrawnIndex;
            delete getWithdrawn[token];
        }

        require(newZkpId > zkpId, "old zkp");
        zkpId = newZkpId;
        lastUpdateTime = block.timestamp;

        emit ZKPUpdated(newZkpId, tokens, newBalanceRoots, newWithdrawRoots, newTotalBalances, newTotalWithdraws);
    }

    function generalWithdraw(
        GeneralWithdrawParams calldata params
    ) external override onlyVerifierSet {
        require(!isWithdrawn(params.token, params.index, true), "Drop already withdrawn");
        require(_verifySignature(params), "wrong signature");

        uint64 zkpId_ = zkpId;
        // Verify the merkle proof.
        uint256[] memory msgs = new uint256[](9);
        msgs[0] = zkpId_;
        msgs[1] = params.index;
        msgs[2] = params.withdrawId;
        msgs[3] = params.accountId;
        msgs[4] = uint256(uint160(params.account));
        msgs[5] = uint256(uint160(params.to));
        msgs[6] = uint256(uint160(params.token));
        msgs[7] = params.withdrawType;
        msgs[8] = params.amount;
        uint256 node = MiMC.Hash(msgs);
        require(MerkleProof.verify(params.proof, getWithdrawRoot[params.token], node), "Invalid proof");
        // Mark it withdrawn and send the token.
        _setWithdrawn(params.token, params.index, true);

        address to = params.to;
        if (params.withdrawType == 0) {
            require(withdrawTreasury != address(0), "withdrawTreasury not set");
            to = withdrawTreasury;
        }

        if (params.token == ETH) {
            TransferHelper.safeTransferETH(to, params.amount);
        } else {
            TransferHelper.safeTransfer(params.token, to, params.amount);
        }

        getWithdrawn[params.token] += params.amount;
        require(getWithdrawn[params.token] <= getTotalWithdraw[params.token], "over totalWithdraw");
        if (getWithdrawn[params.token] == getTotalWithdraw[params.token]) getWithdrawFinished[params.token] = true;

        emit GeneralWithdrawn(params.token, params.account, to, zkpId_, params.index, params.amount, params.withdrawId);
    }

    function forceWithdraw(
        uint256[] calldata proof,
        uint256 index,
        uint256 accountId,
        uint256 equity,
        address token
    ) external override onlyVerifierSet {
        require(block.timestamp > lastUpdateTime + forceTimeWindow, "not over forceTimeWindow");
        require(!isWithdrawn(token, index, false), "Drop already withdrawn");
        uint64 zkpId_ = zkpId;
        // Verify the merkle proof.
        uint256[] memory msgs = new uint256[](5);
        msgs[0] = index;
        msgs[1] = accountId;
        msgs[2] = uint256(uint160(msg.sender));
        msgs[3] = uint256(uint160(token));
        msgs[4] = equity;
        uint256 node = MiMC.Hash(msgs);
        require(MerkleProof.verify(proof, getBalanceRoot[token], node), "Invalid proof");
        // Mark it withdrawn and send the token.
        _setWithdrawn(token, index, false);
        if (token == ETH) {
            TransferHelper.safeTransferETH(msg.sender, equity);
        } else {
            TransferHelper.safeTransfer(token, msg.sender, equity);
        }

        if (!forceWithdrawOpened) forceWithdrawOpened = true;
        emit ForceWithdrawn(token, msg.sender, zkpId_, index, equity); 
    }

    function isWithdrawn(address token, uint256 index, bool isGeneral) public view returns (bool) {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        uint256 word;
        if (isGeneral) {
            word = getWithdrawnInfo[token].generalWithdrawnBitMap[wordIndex];
        } else {
            word = getWithdrawnInfo[token].forceWithdrawnBitMap[wordIndex];
        }
        uint256 mask = (1 << bitIndex);
        return word & mask == mask;
    }

    function _setWithdrawn(address token, uint256 index, bool isGeneral) internal {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        WithdrawnInfo storage withdrawnInfo = getWithdrawnInfo[token];
        if (isGeneral) {
            withdrawnInfo.generalWithdrawnBitMap[wordIndex] = withdrawnInfo.generalWithdrawnBitMap[wordIndex] | (1 << bitIndex);
            withdrawnInfo.allGeneralWithdrawnIndex.push(wordIndex);
        } else {
            withdrawnInfo.forceWithdrawnBitMap[wordIndex] = withdrawnInfo.forceWithdrawnBitMap[wordIndex] | (1 << bitIndex);
            withdrawnInfo.allForceWithdrawnIndex.push(wordIndex);
        }
    }

    function _verifySignature(GeneralWithdrawParams calldata params) internal pure returns (bool) {
        address recover = keccak256(abi.encode(
                params.amount,
                params.to,
                params.chainName,
                params.tokenName,
                params.account,
                params.accountId,
                params.withdrawId,
                params.withdrawType,
                params.expiresAt
            )).toEthSignedMessageHash().recover(params.userSignature);
        require(recover == params.account, "wrong signer");
        return true;
    }
}