
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ownable.sol";
import "./interfaces/IMainTreasury.sol";
import "./libraries/Pairing.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Verifier is Ownable, Initializable {
    event OperatorUpdated(address indexed oldOperator, address indexed newOperator);

    using Pairing for *;

    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    address public operator;
    address public mainTreasury;
    address public usdt;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[5] IC;
    }

    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }

    function initialize(
        address operator_,
        address mainTreasury_, 
        address usdt_
    ) external initializer {
        owner = msg.sender;
        operator = operator_;
        mainTreasury = mainTreasury_;
        usdt = usdt_;
    }

    function updateOperator(address newOperator) external onlyOwner {
        require(newOperator != address(0), "zero address");
        emit OperatorUpdated(operator, newOperator);
        operator = newOperator;
    }

    /*
     * 电路修改后，vk需要同步更新
     */
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(8068120395287175244336770839428908716445703735470448344076644817794901582505), uint256(18960633815518660572178413698159666628246104725880609015101745613948352243988));
        vk.beta2 = Pairing.G2Point([uint256(9584816113340772439789559698711487286337116933359926305886841604448416362843), uint256(7255600291584631216847287413900565247759808928162685652946377864772297244678)], [uint256(7875929535218765123505932845244726371584675564619967172348110079435573644511), uint256(732042519390595344268513721004371806498842494014103315550967660166020751180)]);
        vk.gamma2 = Pairing.G2Point([uint256(14560363400442960933046666704925199691022332293130740364142573570394314446693), uint256(12946235033534680197765439686824505135909070441803362682213184520684509454399)], [uint256(11649976032280821757070139135587543570615214401128117861737713888695227600970), uint256(18792738766123527449325185846675307771611124311698513732171200555610819665204)]);
        vk.delta2 = Pairing.G2Point([uint256(13238427037629852037282667704276821133027996317241929060285437832611168168589), uint256(765874300387660839205890250899134190640783030978940625446240828081771751922)], [uint256(3679879114985348014408003878143511533994307559075514535360429537403117284626), uint256(19701947068263166150615792422230211393157821146232995121781394266876130399656)]);   
        vk.IC[0] = Pairing.G1Point(uint256(2306822424948058289578278726750004764847936298344829202799476619370771718718), uint256(2973769344366619241818877024329439940092311497113156154155084678822239365768));   
        vk.IC[1] = Pairing.G1Point(uint256(2100184902537339313572962146369616144417977972784691916097244552917766415926), uint256(21551633369949332672608707085473720889384964384838901167511945067255213158333));   
        vk.IC[2] = Pairing.G1Point(uint256(5704371724379701090224540678063583205070935507197306015774692264882220206656), uint256(16846242578780372721036173792341150578246319496354182152326641504284177693779));   
        vk.IC[3] = Pairing.G1Point(uint256(8954755641001204912566604977384121957776542603506517628949060409667478210456), uint256(21880951393304707386096997037244002268694659126888243002845457705920529271432));   
        vk.IC[4] = Pairing.G1Point(uint256(1296628761217996536005107266567503330935949641607543010125128787319556039388), uint256(20259598910747006980911139866708639390725359282497918774117597086342168159963));
    }
    
    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[4] memory input
    ) public view returns (bool r) {

        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);

        VerifyingKey memory vk = verifyingKey();
        require(vk.IC.length == input.length + 1, "verifier-IC-length-mismatch");

        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);

        // Make sure that proof.A, B, and C are each less than the prime q
        require(proof.A.X < PRIME_Q, "verifier-aX-gte-prime-q");
        require(proof.A.Y < PRIME_Q, "verifier-aY-gte-prime-q");

        require(proof.B.X[0] < PRIME_Q, "verifier-bX0-gte-prime-q");
        require(proof.B.Y[0] < PRIME_Q, "verifier-bY0-gte-prime-q");

        require(proof.B.X[1] < PRIME_Q, "verifier-bX1-gte-prime-q");
        require(proof.B.Y[1] < PRIME_Q, "verifier-bY1-gte-prime-q");

        require(proof.C.X < PRIME_Q, "verifier-cX-gte-prime-q");
        require(proof.C.Y < PRIME_Q, "verifier-cY-gte-prime-q");

        // Make sure that every input is less than the snark scalar field
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < SNARK_SCALAR_FIELD,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.plus(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }

        vk_x = Pairing.plus(vk_x, vk.IC[0]);

        return Pairing.pairing(
            Pairing.negate(proof.A),
            proof.B,
            vk.alfa1,
            vk.beta2,
            vk_x,
            vk.gamma2,
            proof.C,
            vk.delta2
        );
    }

    // params need to be set memory, if set calldata will come out stack too deep error.
    function submit(
        uint64 zkpId,
        uint256[] memory BeforeAccountTreeRoot,
        uint256[] memory AfterAccountTreeRoot,
        uint256[] memory BeforeCEXAssetsCommitment,
        uint256[] memory AfterCEXAssetsCommitment,
        uint256[2][] memory a, // zk proof参数
        uint256[2][2][] memory b, // zk proof参数
        uint256[2][] memory c, // zk proof参数
        uint256 withdrawMerkelTreeToot,
        uint256 totalBalance,
        uint256 totalWithdraw
    ) public returns (bool r) {
        require(msg.sender == operator, "only operator");
        // 确保输入数组的长度匹配
        require(BeforeAccountTreeRoot.length == AfterAccountTreeRoot.length,"BeforeAccountTreeRoot.length != AfterAccountTreeRoot.length");
        require(BeforeAccountTreeRoot.length == BeforeCEXAssetsCommitment.length,"BeforeAccountTreeRoot.length != BeforeCEXAssetsCommitment.length");
        require(BeforeAccountTreeRoot.length == AfterCEXAssetsCommitment.length,"BeforeAccountTreeRoot.length != AfterCEXAssetsCommitment.length");
        require(BeforeAccountTreeRoot.length == a.length,"BeforeAccountTreeRoot.length != a.length");
        require(BeforeAccountTreeRoot.length == b.length,"BeforeAccountTreeRoot.length != b.length");
        require(BeforeAccountTreeRoot.length == c.length,"BeforeAccountTreeRoot.length != c.length");

        // 确保前一个数据的after值为后一个数据的before值
        for (uint256 i = 1; i < BeforeAccountTreeRoot.length; i++) {
            require(BeforeAccountTreeRoot[i] == AfterAccountTreeRoot[i-1],"BeforeAccountTreeRoot[i] != AfterAccountTreeRoot[i-1]");
            require(BeforeCEXAssetsCommitment[i] == AfterCEXAssetsCommitment[i-1],"BeforeCEXAssetsCommitment[i] != AfterCEXAssetsCommitment[i-1]");
        }

        // 确保zk proof是准确的
        for (uint256 i = 0; i < BeforeAccountTreeRoot.length; i++) {
            uint256[4] memory input = [
                    BeforeAccountTreeRoot[i],
                    AfterAccountTreeRoot[i],
                    BeforeCEXAssetsCommitment[i],
                    AfterCEXAssetsCommitment[i]
                ];
            bool rst = verifyProof(
                a[i],
                b[i],
                c[i],
                input
            );
            require(rst,"zk proof fail");
        }

        _updateZKP(zkpId, AfterAccountTreeRoot[AfterAccountTreeRoot.length - 1], withdrawMerkelTreeToot, totalBalance, totalWithdraw);
        return true;
    }

    function _updateZKP(
        uint64 zkpId,
        uint256 balanceMerkelTreeToot,
        uint256 withdrawMerkelTreeToot,
        uint256 totalBalance,
        uint256 totalWithdraw
    ) internal {
        address[] memory tokens = new address[](1);
        tokens[0] = usdt;
        uint256[] memory newBalanceRoots = new uint256[](1);
        newBalanceRoots[0] = balanceMerkelTreeToot;
        uint256[] memory newWithdrawRoots = new uint256[](1);
        newWithdrawRoots[0] = withdrawMerkelTreeToot;
        uint256[] memory newTotalBalances = new uint256[](1);
        newTotalBalances[0] = totalBalance;
        uint256[] memory newTotalWithdraws = new uint256[](1);
        newTotalWithdraws[0] = totalWithdraw;
        IMainTreasury(mainTreasury).updateZKP(zkpId, tokens, newBalanceRoots, newWithdrawRoots, newTotalBalances, newTotalWithdraws);
    }
}
