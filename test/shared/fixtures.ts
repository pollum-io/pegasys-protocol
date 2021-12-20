import { Contract, Wallet, providers } from 'ethers'
import { deployContract, MockProvider } from 'ethereum-waffle'

import { expandTo18Decimals } from './utilities'

import ERC20 from '../../artifacts/contracts/pegasys-core/test/ERC20.sol/ERC20.json'
import PegasysFactory from '../../artifacts/contracts/pegasys-core/PegasysFactory.sol/PegasysFactory.json'
import PegasysPair from '../../artifacts/contracts/pegasys-core/PegasysPair.sol/PegasysPair.json'

interface FactoryFixture {
  factory: Contract
}

const overrides = {
  gasLimit: 9999999999
}

export async function factoryFixture([wallet]: Wallet[],_: providers.Provider ): Promise<FactoryFixture> {
  const factory = await deployContract(wallet, PegasysFactory, [wallet.address], overrides)
  return { factory }
}

interface PairFixture extends FactoryFixture {
  token0: Contract
  token1: Contract
  pair: Contract
}

export async function pairFixture( [wallet]: Wallet[], provider: providers.Provider,): Promise<PairFixture> {
  const { factory } = await factoryFixture([wallet], provider)

  const tokenA = await deployContract(wallet, ERC20, [expandTo18Decimals(10000)], overrides)
  const tokenB = await deployContract(wallet, ERC20, [expandTo18Decimals(10000)], overrides)

  await factory.createPair(tokenA.address, tokenB.address, overrides)
  const pairAddress = await factory.getPair(tokenA.address, tokenB.address)
  const pair = new Contract(pairAddress, JSON.stringify(PegasysPair.abi), provider).connect(wallet)

  const token0Address = (await pair.token0()).address
  const token0 = tokenA.address === token0Address ? tokenA : tokenB
  const token1 = tokenA.address === token0Address ? tokenB : tokenA

  return { factory, token0, token1, pair }
}
