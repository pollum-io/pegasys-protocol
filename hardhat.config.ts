import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
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

const DEPLOY_PRIV_KEY = process.env.DEPLOY_ACCOUNT_PRIVATE_KEY || "8da4ef21b864d2cc526dbdb2a120bd2874c36c9d0a1fb7f8c63d7f7a8b41de8f";

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
    ]
  },
  networks: {

    tanenbaum: {
      url: 'https://rpc.tanenbaum.io',
      gasPrice: 470000000000,
      chainId: 5700,
      accounts: [DEPLOY_PRIV_KEY]
    },
    localhost: {
      gasPrice: 470000000000,
      chainId: 43114,
      url: "http://127.0.0.1:8545/ext/bc/C/rpc"
    },
    hardhat: {
      gasPrice: 470000000000,
      chainId: 43114,
      initialDate: "2020-10-10",
      forking: {
        url: 'https://api.avax.network/ext/bc/C/rpc',
        enabled: true
      },
      accounts: {
        accountsBalance: "1000000000000000000000000000000",
        count: 50
      }
    },
    sys: {
      url: 'https://rpc.syscoin.org',
      gasPrice: 4000000000,
      accounts: [process.env.DEPLOY_ACCOUNT_PRIVATE_KEY]
    },

  },
  contractSizer: {
    alphaSort: false,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  gasReporter: {
    enabled: true,
    showTimeSpent: true,
    gasPrice: 225
  },
};

export default config;

