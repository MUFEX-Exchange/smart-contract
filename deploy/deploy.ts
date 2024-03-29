// import { Wallet, utils } from "zksync-web3";
// import * as ethers from "ethers";
// import { HardhatRuntimeEnvironment } from "hardhat/types";
// import { Deployer } from "@matterlabs/hardhat-zksync-deploy";

// // An example of a deploy script that will deploy and call a simple contract.
// export default async function (hre: HardhatRuntimeEnvironment) {
//   console.log(`Running deploy script for the Mufex contracts`);

//   // Initialize the wallet.
//   const wallet = new Wallet(
//     "69dcc63ba122221f5b680c9e4d37ca27ebe09a55bf1dce87f5cdce73163b4246"
//   );

//   // Create deployer object and load the artifact of the contract you want to deploy.
//   const deployer = new Deployer(hre, wallet);
//   const artifact = await deployer.loadArtifact("HotTreasury");

//   // Estimate contract deployment fee
//   const deploymentFee = await deployer.estimateDeployFee(artifact, []);

//   // // OPTIONAL: Deposit funds to L2
//   // // Comment this block if you already have funds on zkSync.
//   // const depositHandle = await deployer.zkWallet.deposit({
//   //   to: deployer.zkWallet.address,
//   //   token: utils.ETH_ADDRESS,
//   //   amount: deploymentFee.mul(2),
//   // });
//   // // Wait until the deposit is processed on zkSync
//   // await depositHandle.wait();

//   // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
//   // `greeting` is an argument for contract constructor.
//   const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
//   console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

//   // const hotTreasuryContract = await deployer.deploy(artifact, []);
//   const hotTreasuryContract = await hre.zkUpgrades.deployProxy(
//     deployer.zkWallet,
//     artifact,
//     [],
//     { initializer: "initialize" }
//   );

//   //obtain the Constructor Arguments
//   console.log(
//     "constructor args:" + hotTreasuryContract.interface.encodeDeploy([])
//   );

//   // Show the contract info.
//   const contractAddress = hotTreasuryContract.address;
//   console.log(`${artifact.contractName} was deployed to ${contractAddress}`);

//   // Verify contract programmatically
//   //
//   // Contract MUST be fully qualified name (e.g. path/sourceName:contractName)
//   const contractFullyQualifedName = "contracts/HotTreasury.sol:HotTreasury";
//   const verificationId = await hre.run("verify:verify", {
//     address: contractAddress,
//     contract: contractFullyQualifedName,
//     constructorArguments: [],
//     bytecode: artifact.bytecode,
//   });
//   console.log(
//     `${contractFullyQualifedName} verified! VerificationId: ${verificationId}`
//   );
// }

import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { Wallet } from "zksync-web3";

import * as hre from "hardhat";

async function main() {
  const contractName = "HotTreasury";
  console.log("Deploying " + contractName + "...");

  const zkWallet = new Wallet(
    "69dcc63ba122221f5b680c9e4d37ca27ebe09a55bf1dce87f5cdce73163b4246"
  );

  const deployer = new Deployer(hre, zkWallet);

  const contract = await deployer.loadArtifact(contractName);
  const hotTreasury = await hre.zkUpgrades.deployProxy(
    deployer.zkWallet,
    contract,
    [],
    { initializer: "initialize" }
  );

  await hotTreasury.deployed();
  console.log(contractName + " deployed to:", hotTreasury.address);

  hotTreasury.connect(zkWallet);
  const value = await hotTreasury.retrieve();
  console.log("Box value is: ", value.toNumber());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
