// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SignatureVerifier {
    using ECDSA for bytes32;
    using Strings for uint256;

    bytes32 public immutable DOMAIN_SEPARATOR0;
    bytes32 public immutable DOMAIN_SEPARATOR1;
    bytes32 public constant DOMAIN_TYPEHASH0 =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId)"
        );
    bytes32 public constant DOMAIN_TYPEHASH1 =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH1 =
        keccak256(
            "Withdraw(string chainName)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH2 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH3 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH4 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName,string tokenName)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH5 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName,string tokenName,uint256 accountId)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH6 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName,string tokenName,uint256 accountId,uint256 fee)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH7 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName,string tokenName,uint256 accountId,uint256 fee,string withdrawId)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH8 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName,string tokenName,uint256 accountId,uint256 fee,string withdrawId,string expiresAt)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH9 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName,string tokenName,uint256 accountId,uint256 fee,string withdrawId,string expiresAt,address to)"
        );
    bytes32 public constant WITHDRAW_TYPEHASH10 =
        keccak256(
            "Withdraw(uint8 withdrawType,uint256 amount,string chainName,string tokenName,uint256 accountId,uint256 fee,string withdrawId,string expiresAt,address to,address account)"
        );

    constructor() {
        DOMAIN_SEPARATOR0 = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH0,
                keccak256(bytes("MUFEX")),
                keccak256(bytes("1")),
                block.chainid
            )
        );
        DOMAIN_SEPARATOR1 = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH1,
                keccak256(bytes("MUFEX")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    function verify0(address account, string calldata chainName, uint8 v, bytes32 r, bytes32 s) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR0,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH1,
                        keccak256(bytes(chainName))
                    )
                )
            )
        );
        recover = ecrecover(digest, v, r, s);
        success = (recover == account);
    }

    function verify1(address account, string calldata chainName, uint8 v, bytes32 r, bytes32 s) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH1,
                        keccak256(bytes(chainName))
                    )
                )
            )
        );
        recover = ecrecover(digest, v, r, s);
        success = (recover == account);
    }

    function verify2(
        address account, 
        uint8 withdrawType, 
        uint256 amount,
        uint8 v, bytes32 r, bytes32 s
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH2,
                        withdrawType,
                        amount
                    )
                )
            )
        );
        recover = ecrecover(digest, v, r, s);
        success = (recover == account);
    }

    function verify3(
        address account, 
        uint8 withdrawType, 
        uint256 amount,
        string calldata chainName,
        uint8 v, bytes32 r, bytes32 s
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH3,
                        withdrawType,
                        amount,
                        keccak256(bytes(chainName))
                    )
                )
            )
        );
        recover = ecrecover(digest, v, r, s);
        success = (recover == account);
    }

    function verify4(
        address account, 
        uint8 withdrawType, 
        uint256 amount,
        string calldata chainName,
        string calldata tokenName,
        uint8 v, bytes32 r, bytes32 s
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH4,
                        withdrawType,
                        amount,
                        keccak256(bytes(chainName)),
                        keccak256(bytes(tokenName))
                    )
                )
            )
        );
        recover = ecrecover(digest, v, r, s);
        success = (recover == account);
    }

    function verify5(
        address account, 
        uint8 withdrawType, 
        uint256 amount,
        string calldata chainName,
        string calldata tokenName,
        uint256 accountId,
        uint8 v, bytes32 r, bytes32 s
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH5,
                        withdrawType,
                        amount,
                        keccak256(bytes(chainName)),
                        keccak256(bytes(tokenName)),
                        accountId
                    )
                )
            )
        );
        recover = ecrecover(digest, v, r, s);
        success = (recover == account);
    }

    function verify6(
        address account, 
        uint8 withdrawType, 
        uint256 amount,
        string calldata chainName,
        string calldata tokenName,
        uint256 accountId,
        uint256 fee,
        uint8 v, bytes32 r, bytes32 s
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH6,
                        withdrawType,
                        amount,
                        keccak256(bytes(chainName)),
                        keccak256(bytes(tokenName)),
                        accountId,
                        fee
                    )
                )
            )
        );
        recover = ecrecover(digest, v, r, s);
        success = (recover == account);
    }

    struct Param7 {
        address account;
        uint8 withdrawType; 
        uint256 amount;
        string chainName;
        string tokenName;
        uint256 accountId;
        uint256 fee;
        uint256 withdrawId;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function verify7(
        Param7 calldata param
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH7,
                        param.withdrawType,
                        param.amount,
                        keccak256(bytes(param.chainName)),
                        keccak256(bytes(param.tokenName)),
                        param.accountId,
                        param.fee,
                        keccak256(bytes(param.withdrawId.toHexString()))
                    )
                )
            )
        );
        recover = ecrecover(digest, param.v, param.r, param.s);
        success = (recover == param.account);
    }

    struct Param8 {
        address account;
        uint8 withdrawType; 
        uint256 amount;
        string chainName;
        string tokenName;
        uint256 accountId;
        uint256 fee;
        uint256 withdrawId;
        string expiresAt;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function verify8(
        Param8 calldata param
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH8,
                        param.withdrawType,
                        param.amount,
                        keccak256(bytes(param.chainName)),
                        keccak256(bytes(param.tokenName)),
                        param.accountId,
                        param.fee,
                        keccak256(bytes(param.withdrawId.toHexString())),
                        keccak256(bytes(param.expiresAt))
                    )
                )
            )
        );
        recover = ecrecover(digest, param.v, param.r, param.s);
        success = (recover == param.account);
    }

    struct Param9 {
        address account;
        uint8 withdrawType; 
        uint256 amount;
        string chainName;
        string tokenName;
        uint256 accountId;
        uint256 fee;
        uint256 withdrawId;
        string expiresAt;
        address to;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function verify9(
        Param9 memory param
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH9,
                        param.withdrawType,
                        param.amount,
                        keccak256(bytes(param.chainName)),
                        keccak256(bytes(param.tokenName)),
                        param.accountId,
                        param.fee,
                        keccak256(bytes(param.withdrawId.toHexString())),
                        keccak256(bytes(param.expiresAt)),
                        param.to
                    )
                )
            )
        );
        recover = ecrecover(digest, param.v, param.r, param.s);
        success = (recover == param.account);
    }

    function verify10(
        Param9 memory param
    ) external view returns (bytes32 digest, address recover, bool success) {
        digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR1,
                keccak256(
                    abi.encode(
                        WITHDRAW_TYPEHASH10,
                        param.withdrawType,
                        param.amount,
                        keccak256(bytes(param.chainName)),
                        keccak256(bytes(param.tokenName)),
                        param.accountId,
                        param.fee,
                        keccak256(bytes(param.withdrawId.toHexString())),
                        keccak256(bytes(param.expiresAt)),
                        param.to,
                        param.account
                    )
                )
            )
        );
        recover = ecrecover(digest, param.v, param.r, param.s);
        success = (recover == param.account);
    }

    function convertUint256ToHexString(uint256 withdrawId) external pure returns (string memory) {
        return withdrawId.toHexString();
    }
}