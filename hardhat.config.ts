import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-contract-sizer";
import "hardhat-gas-reporter";
import "hardhat-tracer";
import { task, HardhatUserConfig } from "hardhat/config";
import "ts-node/register";
const dotenv = require('dotenv');
dotenv.config();
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const DEPLOY_PRIV_KEY: string = process.env.DEPLOY_ACCOUNT_PRIVATE_KEY || '';

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.5.16"
      },
      {
        version: "0.6.2"
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"],
            },
          },
        }
      },
      {
        version: "0.6.12"
      },
      {
        version: "0.7.0"
      },
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"],
            },
          },
        }
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000
          },
          outputSelection: {
            "*": {
              "*": ["storageLayout"],
            },
          },
        }
      },
      {
        version: "0.8.7",
      }
    ]
  },
  networks: {
    hardhat: {
      hardfork: "london",
      gasPrice: "auto",
      initialBaseFeePerGas: 1_000_000_000
    },
    tanenbaum: {
      url: 'https://rpc.tanenbaum.io/',
      gasPrice: "auto",
      hardfork: "london",
      chainId: 5700,
      accounts: [DEPLOY_PRIV_KEY]
    },
    localhost: {
      gasPrice: 470000000000,
      chainId: 43114,
      url: "http://127.0.0.1:8545/ext/bc/C/rpc"
    },
    sys: {
      url: 'https://rpc.syscoin.org',
      gasPrice: "auto",
      hardfork: "london",
      chainId: 57,
      accounts: [DEPLOY_PRIV_KEY]
    },
    ropsten: {
      url: process.env.ROPSTEN_URL,
      accounts: [DEPLOY_PRIV_KEY]
    },

  },
  contractSizer: {
    alphaSort: false,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  },
  gasReporter: {
    enabled: true,
    showTimeSpent: true,
    gasPrice: 225
  },
};

export default config;

