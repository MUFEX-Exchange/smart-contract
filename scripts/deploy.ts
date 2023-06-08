import { ethers, upgrades } from "hardhat";

async function main() {
  const verifyStr = "npx hardhat verify --network";
  const USDT = "0x84f3eBe8048C5047b35bd2c70E1EEE4dC4b755b6"; // Arbitrum Goerli
  const operator = "0xdC8CcBD393E80b91E7bbD93dd8513c50D51933f4";

  const HotTreasury = await ethers.getContractFactory("HotTreasury");
  const hotTreasury = await HotTreasury.deploy();
  console.log("HotTreasury", hotTreasury.address);
  console.log(verifyStr, process.env.HARDHAT_NETWORK, hotTreasury.address);

  const MainTreasury = await ethers.getContractFactory("MainTreasury");
  const mainTreasury = await MainTreasury.deploy();
  console.log("MainTreasury", mainTreasury.address);
  console.log(verifyStr, process.env.HARDHAT_NETWORK, mainTreasury.address);

  const Verifier = await ethers.getContractFactory("Verifier");
  const verifier = await Verifier.deploy();
  console.log("Verifier", verifier.address);
  console.log(verifyStr, process.env.HARDHAT_NETWORK, verifier.address);

  const DepositWalletFactory = await ethers.getContractFactory(
    "DepositWalletFactory"
  );
  const depositWalletFactory = await DepositWalletFactory.deploy(
    mainTreasury.address
  );
  console.log("DepositWalletFactory:", depositWalletFactory.address);
  console.log(
    verifyStr,
    process.env.HARDHAT_NETWORK,
    depositWalletFactory.address,
    mainTreasury.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
