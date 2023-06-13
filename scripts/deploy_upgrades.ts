import { ethers, upgrades } from "hardhat";

async function main() {
  const verifyStr = "npx hardhat verify --network";
  // // const USDT = "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9"; // Arbitrum One
  // // const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F"; // Polygon Mainnet
  // // const USDT = "0xd44BB808bfE43095dBb94c83077766382D63952a"; // Goerli
  // // const USDT = "0x84f3eBe8048C5047b35bd2c70E1EEE4dC4b755b6"; // Arbitrum Goerli
  // const USDT = "0x665f1c610b32bb793e9ae5f09ea5dddd0e407e1a"; // Polygon Mumbai
  // const operator = "0x0931f6dd007a86e4c5a6f10ed00810c9fd1d6a3b";
  // // const operator = "0xcfb32e61535e13b482f7684de7c784611455a214";

  // const HotTreasury = await ethers.getContractFactory("HotTreasury");
  // const hotTreasury = await upgrades.deployProxy(HotTreasury, []);
  // await hotTreasury.deployed();
  // const hotTreasuryAddresses = {
  //   proxy: hotTreasury.address,
  //   admin: await upgrades.erc1967.getAdminAddress(hotTreasury.address),
  //   implementation: await upgrades.erc1967.getImplementationAddress(
  //     hotTreasury.address
  //   ),
  // };
  // console.log("HotTreasury Addresses:", hotTreasuryAddresses);
  // await hotTreasury.addOperator(operator);

  // const MainTreasury = await ethers.getContractFactory("MainTreasury");
  // const mainTreasury = await upgrades.deployProxy(MainTreasury, [604800]);
  // await mainTreasury.deployed();
  // const mainTreasuryAddresses = {
  //   proxy: mainTreasury.address,
  //   admin: await upgrades.erc1967.getAdminAddress(mainTreasury.address),
  //   implementation: await upgrades.erc1967.getImplementationAddress(
  //     mainTreasury.address
  //   ),
  // };
  // console.log("MainTreasury Addresses:", mainTreasuryAddresses);
  // await mainTreasury.addOperator(operator);

  // const Verifier = await ethers.getContractFactory("Verifier");
  // const verifier = await upgrades.deployProxy(Verifier, [
  //   operator,
  //   mainTreasury.address,
  //   USDT,
  // ]);
  // await verifier.deployed();
  // const verifierAddresses = {
  //   proxy: verifier.address,
  //   admin: await upgrades.erc1967.getAdminAddress(verifier.address),
  //   implementation: await upgrades.erc1967.getImplementationAddress(
  //     verifier.address
  //   ),
  // };
  // console.log("Verifier Addresses:", verifierAddresses);

  // await mainTreasury.setVerifier(verifier.address);

  const DepositWalletFactory = await ethers.getContractFactory(
    "DepositWalletFactory"
  );
  const depositWalletFactory = await upgrades.deployProxy(
    DepositWalletFactory,
    ["0x763ecd00eEA0CDAECBDF97d88c3e0fd5457eE5A0"]
  );
  await depositWalletFactory.deployed();
  const depositWalletFactoryAddresses = {
    proxy: depositWalletFactory.address,
    admin: await upgrades.erc1967.getAdminAddress(depositWalletFactory.address),
    implementation: await upgrades.erc1967.getImplementationAddress(
      depositWalletFactory.address
    ),
  };
  console.log("DepositWalletFactory Addresses:", depositWalletFactoryAddresses);

  // const mainTreasury = await ethers.getContractAt(
  //   "MainTreasury",
  //   "0xf2Dc2D31c75aC0BBB7cFDc30475fcbF38F520AF9"
  // );
  // await mainTreasury.setPendingOwner(
  //   "0xDB0c0c2e0A54372a2C1134941c4Ee6414e582371"
  // );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
