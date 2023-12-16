import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
// import "@openzeppelin/hardhat-upgrades";
import * as dotenv from 'dotenv';
dotenv.config();

const HARDHAT_DEPLOYER_PRIVATE_KEY = process.env.HARDHAT_DEPLOYER_PRIVATE_KEY;

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
    hardhat: {
      chainId: 1337,
    },
    ganache: {
      url: 'http://127.0.0.1:7545',
      accounts: [HARDHAT_DEPLOYER_PRIVATE_KEY as string],
    },
  },
};

export default config;
