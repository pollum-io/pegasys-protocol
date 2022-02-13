# Pegasys Smart Contracts
[![npm](https://img.shields.io/npm/v/@pollum-io/pegasys-protocol)](https://unpkg.com/@pollum-io/pegasys-protocol@latest/)

This repo contains all of the smart contracts used to run [Pegasys](pegasys.finance). It is also distributed through [NPM](https://www.npmjs.com/package/@pollum-io/pegasys-protocol).

## Deployed Contracts

### Syscoin NEVM:

Pegasys Token: `0xE18c200A70908c89fFA18C628fE1B83aC0065EA4`

Factory address: `0x7Bbbb6abaD521dE677aBe089C85b29e3b2021496`

Router address: `0x017dAd2578372CAEE5c6CddfE35eEDB3728544C4`

Migrator address: `0xd4F7cE01bef778359ff02dab31cA48f431C630d5`

MiniChefV2: `0x27F037100118548c63F945e284956073D1DC76dE`

### Syscoin Tanenbaum Testnet:

Factory address: `0x577CCB2eF53F56AC9b16E0Db6550a6bAe6ba27bc`

Router address: `0xE18c200A70908c89fFA18C628fE1B83aC0065EA4`

Migrator address: `0xcDa164cb93979d714CC8B0D3e1ab829E81469649`
## Running
These contracts are compiled and deployed using [Hardhat](https://hardhat.org/).

To prepare the dev environment, run `yarn install`. To compile the contracts, run `yarn compile`. Yarn is available to install [here](https://classic.yarnpkg.com/en/docs/install/#debian-stable) if you need it.

## Attribution
These contracts were adapted from these Uniswap & Pangolin repos: [governance](https://github.com/pangolindex/governance), [exchange-contracts](https://github.com/pangolindex/exchange-contracts), [uniswap-v2-core](https://github.com/Uniswap/uniswap-v2-core), [uniswap-v2-periphery](https://github.com/Uniswap/uniswap-v2-core), and [uniswap-lib](https://github.com/Uniswap/uniswap-lib).
