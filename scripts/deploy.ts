import { ethers, upgrades } from "hardhat";

async function main() {
  const verifyStr = "npx hardhat verify --network";

  // const HotTreasury = await ethers.getContractFactory("HotTreasury");
  // const hotTreasury = await HotTreasury.deploy();
  // console.log("HotTreasury", hotTreasury.address);
  // console.log(verifyStr, process.env.HARDHAT_NETWORK, hotTreasury.address);

  // const MainTreasury = await ethers.getContractFactory("MainTreasury");
  // const mainTreasury = await MainTreasury.deploy();
  // console.log("MainTreasury", mainTreasury.address);
  // console.log(verifyStr, process.env.HARDHAT_NETWORK, mainTreasury.address);

  // const Verifier = await ethers.getContractFactory("Verifier");
  // const verifier = await Verifier.deploy();
  // console.log("Verifier", verifier.address);
  // console.log(verifyStr, process.env.HARDHAT_NETWORK, verifier.address);

  // const DepositWalletFactory = await ethers.getContractFactory(
  //   "DepositWalletFactory"
  // );
  // const depositWalletFactory = await DepositWalletFactory.deploy();
  // console.log("DepositWalletFactory:", depositWalletFactory.address);
  // console.log(
  //   verifyStr,
  //   process.env.HARDHAT_NETWORK,
  //   depositWalletFactory.address
  // );

  // const treasury = await ethers.getContractAt(
  //   "DepositWalletFactory",
  //   "0xEa0243569E25e393120E1B692507E0cba606f6E9"
  // );
  // await treasury.setPendingOwner("0xdb0c0c2e0a54372a2c1134941c4ee6414e582371");
  // console.log("success");

  const SignatureVerifier = await ethers.getContractFactory(
    "SignatureVerifier"
  );
  const signatureVerifier = await SignatureVerifier.deploy();
  console.log(
    verifyStr,
    process.env.HARDHAT_NETWORK,
    signatureVerifier.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
