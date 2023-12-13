import { ethers } from 'hardhat';
import { time, loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { anyValue } from '@nomicfoundation/hardhat-chai-matchers/withArgs';
import { type HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { expect } from 'chai';
import { BigNumber } from '@ethersproject/bignumber';
import FileReader from '../utils/fs';

describe('Test', function () {
  async function init(): Promise<HardhatEthersSigner[]> {
    const [admin, user1] = await ethers.getSigners();
    return [admin, user1];
  }

  async function deployBasic(): Promise<any> {
    const [admin, test] = await loadFixture(init);
    console.log(admin);
    console.log(test);

    const Basic = await ethers.getContractFactory('Basic');
    const basic = await Basic.connect(admin).deploy();
    await basic.waitForDeployment();

    return { basic };
  }

  describe('Run contract', function () {
    it('should get data', async function () {
      const reader = new FileReader();
    });
  });
});
