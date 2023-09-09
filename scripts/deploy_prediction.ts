import { ethers, upgrades } from "hardhat";

async function main() {
  const verifyStr = "npx hardhat verify --network";

  const token = "0x2ed3c15ec59ce827c4abbabff76d37562558437d";
  const oracleAddress = "0xA2aa501b19aff244D90cc15a4Cf739D2725B5729";
  const priceFeedId =
    "0xca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6";
  const adminAddress = "0x1D1A00AC9d21e730238442a2a4a68ca787Ec4bBF";
  const operatorAddress = "0xC37fd327a09A3eC0df4885c366474C5E46119Cd0";
  const intervalSeconds = 300;
  const bufferSeconds = 30;
  const minBetAmount = 1000000000000000;
  const oracleUpdateAllowance = 300;
  const treasuryFee = 300;

  const Prediction = await ethers.getContractFactory("Prediction");
  const prediction = await Prediction.deploy(
    token,
    oracleAddress,
    priceFeedId,
    adminAddress,
    operatorAddress,
    intervalSeconds,
    bufferSeconds,
    minBetAmount,
    oracleUpdateAllowance,
    treasuryFee
  );
  console.log("Prediction", prediction.address);
  console.log(
    verifyStr,
    process.env.HARDHAT_NETWORK,
    prediction.address,
    token,
    oracleAddress,
    priceFeedId,
    adminAddress,
    operatorAddress,
    intervalSeconds,
    bufferSeconds,
    minBetAmount,
    oracleUpdateAllowance,
    treasuryFee
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
