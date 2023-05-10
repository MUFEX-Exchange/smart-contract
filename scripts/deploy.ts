import { ethers } from "hardhat";

async function main() {
  const verifyStr = "npx hardhat verify --network";
  const operator = "0xdC8CcBD393E80b91E7bbD93dd8513c50D51933f4";
  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(operator);
  console.log("Treasury:", treasury.address);
  console.log(
    verifyStr,
    process.env.HARDHAT_NETWORK,
    treasury.address,
    operator
  );

  const MainTreasury = await ethers.getContractFactory("MainTreasury");
  const mainTreasury = await MainTreasury.deploy(operator);
  console.log("MainTreasury:", mainTreasury.address);
  console.log(
    verifyStr,
    process.env.HARDHAT_NETWORK,
    mainTreasury.address,
    operator
  );

  const DepositWalletFactory = await ethers.getContractFactory(
    "DepositWalletFactory"
  );
  const depositWalletFactory = await DepositWalletFactory.deploy(
    treasury.address
  );
  console.log("DepositWalletFactory:", depositWalletFactory.address);
  console.log(
    verifyStr,
    process.env.HARDHAT_NETWORK,
    depositWalletFactory.address,
    treasury.address
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
