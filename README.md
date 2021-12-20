# Pegasys Smart Contracts
This repo contains all of the smart contracts used to run [Pegasys](pegasys.finance).

## Deployed Contracts

### Syscoin Tanenbaum Testnet:
Factory address: `0x8e59ED2DF847Ad3d19624480Db5B2B3Ba27fC9a8`

Router address: `0x11C7a9EC6D27BbDf6abCef518e259d4E4d429DD6`

Migrator address: `0xE62751f52b55fcFae16144f5784c44418fb535D7`

### Syscoin NEVM:
Factory address: `0x4DFc340487bbec780bA8458e614b732d7226AE8f`

Router address: `soon`

Migrator address: `0x13517674e6f8794973f70B37CcF06676023E69Cc`

## Running
These contracts are compiled and deployed using [Hardhat](https://hardhat.org/).

To prepare the dev environment, run `yarn install`. To compile the contracts, run `yarn compile`. Yarn is available to install [here](https://classic.yarnpkg.com/en/docs/install/#debian-stable) if you need it.

## Attribution
These contracts were adapted from these Uniswap & Pangolin repos: [exchange-contracts](https://github.com/pangolindex/exchange-contracts), [uniswap-v2-core](https://github.com/Uniswap/uniswap-v2-core), [uniswap-v2-periphery](https://github.com/Uniswap/uniswap-v2-core), and [uniswap-lib](https://github.com/Uniswap/uniswap-lib).
