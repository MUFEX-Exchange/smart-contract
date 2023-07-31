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
const OPBNB_TESTNET_URL = process.env.OPBNB_TESTNET_URL;
const LINEA_TESTNET_URL = process.env.LINEA_TESTNET_URL;
const POLYGON_ZKEVM_TESTNET_URL = process.env.POLYGON_ZKEVM_TESTNET_URL;
const MANTLE_TESTNET_URL = process.env.MANTLE_TESTNET_URL;
const BASE_TESTNET_URL = process.env.BASE_TESTNET_URL;
const BSC_MAINNET_URL = process.env.BSC_MAINNET_URL;

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const ARBISCAN_API_KEY = process.env.ARBISCAN_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;
const BSC_API_KEY = process.env.BSC_API_KEY;

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
      gasPrice: 35000000000,
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
    opBNBTestnet: {
      url: OPBNB_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
      gasPrice: 35000000000,
    },
    lineaTestnet: {
      url: LINEA_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    polygonZKEVMTestnet: {
      url: POLYGON_ZKEVM_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    mantleTestnet: {
      url: MANTLE_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
    baseTestnet: {
      url: BASE_TESTNET_URL,
      accounts: [`${PRIVATE_KEY}`],
      gasPrice: 35000000000,
    },
    bscMainnet: {
      url: BSC_MAINNET_URL,
      accounts: [`${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    // apiKey: BSC_API_KEY,
    apiKey: ARBISCAN_API_KEY,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
};

export default config;

// // for zkSync
// import "@matterlabs/hardhat-zksync-solc";
// import "@matterlabs/hardhat-zksync-deploy";
// // upgradable plugin
// import "@matterlabs/hardhat-zksync-upgradable";

// import { HardhatUserConfig } from "hardhat/config";

// const config: HardhatUserConfig = {
//   zksolc: {
//     version: "latest",
//     settings: {},
//   },
//   defaultNetwork: "zkSyncNetwork",
//   networks: {
//     goerli: {
//       zksync: false,
//       url: "http://localhost:8545",
//     },
//     zkSyncNetwork: {
//       zksync: true,
//       ethNetwork: "goerli",
//       url: "http://localhost:3050",
//     },
//   },
//   solidity: {
//     version: "0.8.19",
//   },
// };

// export default config;
