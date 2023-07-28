import { ethers, upgrades } from "hardhat";

async function main() {
  const verifyStr = "npx hardhat verify --network";
  // const USDT = "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9"; // Arbitrum One
  // const USDT = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F"; // Polygon Mainnet
  // const USDT = "0xd44BB808bfE43095dBb94c83077766382D63952a"; // Goerli
  // const USDT = "0x84f3eBe8048C5047b35bd2c70E1EEE4dC4b755b6"; // Arbitrum Goerli
  // const USDT = "0x665f1c610b32bb793e9ae5f09ea5dddd0e407e1a"; // Polygon Mumbai
  // const USDT = "0xffa501dff91737ff5fafdaa788b8d00002034b6c"; // bscTestnet
  const USDT = "0xf56dc6695cF1f5c364eDEbC7Dc7077ac9B586068"; // Linea Testnet

  const operator = "0xC37fd327a09A3eC0df4885c366474C5E46119Cd0"; // Testnet
  // const operator = "0xcfb32e61535e13b482f7684de7c784611455a214"; // Mainnet

  const HotTreasury = await ethers.getContractFactory("HotTreasury");
  const hotTreasury = await upgrades.deployProxy(HotTreasury, []);
  await hotTreasury.deployed();
  await hotTreasury.addOperator(operator);
  const hotTreasuryAddresses = {
    proxy: hotTreasury.address,
    admin: await upgrades.erc1967.getAdminAddress(hotTreasury.address),
    implementation: await upgrades.erc1967.getImplementationAddress(
      hotTreasury.address
    ),
  };
  console.log("HotTreasury Addresses:", hotTreasuryAddresses);

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
    [hotTreasury.address]
  );
  await depositWalletFactory.deployed();
  await depositWalletFactory.addOperator(operator);
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
  // await hotTreasury.setPendingOwner(
  //   "0xDB0c0c2e0A54372a2C1134941c4Ee6414e582371"
  // );
  // await mainTreasury.setPendingOwner(
  //   "0xDB0c0c2e0A54372a2C1134941c4Ee6414e582371"
  // );
  // await verifier.setPendingOwner("0xDB0c0c2e0A54372a2C1134941c4Ee6414e582371");
  // await depositWalletFactory.setPendingOwner(
  //   "0xDB0c0c2e0A54372a2C1134941c4Ee6414e582371"
  // );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
