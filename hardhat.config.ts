import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-contract-sizer";
import dotenv from "dotenv";
dotenv.config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const GOERLI_URL = process.env.GOERLI_URL;
const ARBITRUM_ONE_URL = process.env.ARBITRUM_ONE_URL;
const ARBITRUM_GOERLI_URL = process.env.ARBITRUM_GOERLI_URL;
const BSC_TESTNET_URL = process.env.BSC_TESTNET_URL;
const POLYGON_MAINNET_URL = process.env.POLYGON_MAINNET_URL;
const POLYGON_MUMBAI_URL = process.env.POLYGON_MUMBAI_URL;
const SCROLL_TESTNET_URL = process.env.SCROLL_TESTNET_URL;
const ZKSYNC_TESTNET_URL = process.env.ZKSYNC_TESTNET_URL;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const ARBISCAN_API_KEY = process.env.ARBISCAN_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.18",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    goerli: {
      url: GOERLI_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    arbitrumOne: {
      url: ARBITRUM_ONE_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    arbitrumGoerli: {
      url: ARBITRUM_GOERLI_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    bscTestnet: {
      url: BSC_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    polygonMainnet: {
      url: POLYGON_MAINNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    polygonMumbai: {
      url: POLYGON_MUMBAI_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    scrollTestnet: {
      url: SCROLL_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    zkSyncTestnet: {
      url: ZKSYNC_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    // apiKey: POLYGONSCAN_API_KEY,
    apiKey: ARBISCAN_API_KEY,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
};

export default config;

//// for zkSync
// import "@matterlabs/hardhat-zksync-deploy";
// import "@matterlabs/hardhat-zksync-solc";
// import "@matterlabs/hardhat-zksync-verify";

// module.exports = {
//   zksolc: {
//     version: "latest", // Uses latest available in https://github.com/matter-labs/zksolc-bin/
//     settings: {},
//   },
//   defaultNetwork: "zkSyncTestnet",

//   networks: {
//     zkSyncTestnet: {
//       url: "https://testnet.era.zksync.dev",
//       ethNetwork: "goerli", // RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
//       zksync: true,
//       verifyURL:
//         "https://zksync2-testnet-explorer.zksync.dev/contract_verification", // Verification endpoint
//     },
//   },
//   solidity: {
//     compilers: [
//       {
//         version: "0.8.18",
//         settings: {
//           optimizer: {
//             enabled: true,
//             runs: 200,
//           },
//         },
//       },
//     ],
//   },
// };
