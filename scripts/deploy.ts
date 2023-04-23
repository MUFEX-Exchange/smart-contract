import { ethers } from "hardhat";

async function main() {
  const operator = "0x1956b2c4C511FDDd9443f50b36C4597D10cD9985";
  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(operator);
  console.log("Treasury:", treasury.address);

  const MainTreasury = await ethers.getContractFactory("MainTreasury");
  const mainTreasury = await MainTreasury.deploy(operator);
  console.log("MainTreasury:", mainTreasury.address);

  const DepositWalletFactory = await ethers.getContractFactory(
    "DepositWalletFactory"
  );
  const depositWalletFactory = await DepositWalletFactory.deploy(
    treasury.address
  );
  console.log("DepositWalletFactory:", depositWalletFactory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
