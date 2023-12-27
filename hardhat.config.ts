import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
// import "@openzeppelin/hardhat-upgrades";
import * as dotenv from 'dotenv';
dotenv.config();
import { userConfig } from './src/accounts';

const GANACHE_DEPLOYER_PRIVATE_KEY = process.env.GANACHE_DEPLOYER_PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.20',
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
      // viaIR: true,
    },
  },
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    hardhat: {
      chainId: 1337,
      accounts: userConfig,
    },
    ganache: {
      url: 'http://127.0.0.1:7545',
      accounts: [GANACHE_DEPLOYER_PRIVATE_KEY as string],
    },
  },
};

export default config;
