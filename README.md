# Pegasys Smart Contracts
[![npm](https://img.shields.io/npm/v/@pollum-io/pegasys-protocol)](https://unpkg.com/@pollum-io/pegasys-protocol@latest/)

This repo contains all of the smart contracts used to run [Pegasys](pegasys.finance). It is also distributed through [NPM](https://www.npmjs.com/package/@pollum-io/pegasys-protocol).

## Deployed Contracts

### Syscoin NEVM:

Pegasys Token: `0xE18c200A70908c89fFA18C628fE1B83aC0065EA4`

Factory address: `0x7Bbbb6abaD521dE677aBe089C85b29e3b2021496`

Router address: `0x017dAd2578372CAEE5c6CddfE35eEDB3728544C4`

MiniChefV2: `0x27F037100118548c63F945e284956073D1DC76dE`

TimeLock: `0x2C4ce5DcE61b22d9eed75136CD5C8bbd788A243B`

GovernorAlpha: `0x633Bdeb5D4b5f93933833A692e230a7d48fC2d77`

PegasysStaking: `0x1e6dc4CB2F98817A0E3D850Bba7aEfa3CFcdE55F`

### Syscoin Tanenbaum Testnet:

Factory address: `0x577CCB2eF53F56AC9b16E0Db6550a6bAe6ba27bc`

Router address: `0xE18c200A70908c89fFA18C628fE1B83aC0065EA4`

## Running
These contracts are compiled and deployed using [Hardhat](https://hardhat.org/).

To prepare the dev environment, run `yarn install`. To compile the contracts, run `yarn compile`. Yarn is available to install [here](https://classic.yarnpkg.com/en/docs/install/#debian-stable) if you need it.

## Attribution
These contracts were adapted from these Uniswap & Pangolin repos: [governance](https://github.com/pangolindex/governance), [exchange-contracts](https://github.com/pangolindex/exchange-contracts), [uniswap-v2-core](https://github.com/Uniswap/uniswap-v2-core), [uniswap-v2-periphery](https://github.com/Uniswap/uniswap-v2-core), and [uniswap-lib](https://github.com/Uniswap/uniswap-lib).
