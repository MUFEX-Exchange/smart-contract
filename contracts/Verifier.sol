
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
        vk.alfa1 = Pairing.G1Point(uint256(10182039344130542708251772218324566215111918275826079967613590121230118648139), uint256(12020534790629792498292461888501637766332211372317938067393471103542582278504));
        vk.beta2 = Pairing.G2Point([uint256(8900123831730408997721629562529806455674352818721050893145981561846406678678), uint256(4150682596837903001655470341051315808449385842806883920551141506448711056335)], [uint256(20092859076136992696224367461334939196103774917496929036291176282574132490932), uint256(784797088644587301524739338722379799532184367516661151049987037445214956762)]);
        vk.gamma2 = Pairing.G2Point([uint256(12808182132425148684051662275556978964607679176107643485172076309235903291097), uint256(10020410929058386689903777088376824160842427602250818968090639483234994219891)], [uint256(2028411649104841423417956514284395951423724253260260562601598942773903883355), uint256(2817070479843129349742030589324217272653807308568717622222864430839719415594)]);
        vk.delta2 = Pairing.G2Point([uint256(6853721912202184086575277993829278772224360370753737408013395050573709754402), uint256(11941291807834245105186554605347563978585500532923379219103606833990832137824)], [uint256(13309290357704223353980044999110174203343304755324814847622449102781528948192), uint256(6185736462027280559616662714766358304873017379691439466398160695960357960321)]);   
        vk.IC[0] = Pairing.G1Point(uint256(11811450032330300592535716189552169649309870859959888462359993785207429217268), uint256(20690534449777340499403728980633893498066840603595050107506136262814672554805));   
        vk.IC[1] = Pairing.G1Point(uint256(1755120797216240200915801983021240747384229251168348203308247062335092888597), uint256(1755329506835174594750834777414866578652895529174290034368106803183575160889));   
        vk.IC[2] = Pairing.G1Point(uint256(13259911270394834434835151910803478663186519373486026572489209329701220074843), uint256(16682765381924980802512800273858767095051334860793101794108233384703119020920));   
        vk.IC[3] = Pairing.G1Point(uint256(2560382437228511314479405513271343419368295050935762851780076133395929766004), uint256(813507783090300384403268898233933469172651822203540838451128661960037589850));   
        vk.IC[4] = Pairing.G1Point(uint256(6660266506840122788455474013507249223213779969488426976055774842752851196678), uint256(17777056475770638240467766511097090275673930937432869850137685084809625484385));
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
