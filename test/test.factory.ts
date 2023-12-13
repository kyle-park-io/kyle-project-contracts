import { ethers } from 'hardhat';
import { type Token, type DexCalc, type Factory } from 'typechain-types';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { type HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { expect } from 'chai';

describe('Test', function () {
  async function init(): Promise<HardhatEthersSigner[]> {
    const [admin, user1] = await ethers.getSigners();
    return [admin, user1];
  }

  async function deployContracts(): Promise<{
    factory: Factory;
    dexCalc: DexCalc;
    tokenA: Token;
    tokenB: Token;
  }> {
    const [admin] = await loadFixture(init);

    const Factory = await ethers.getContractFactory('Factory');
    const factory = await Factory.connect(admin).deploy(admin.address);
    await factory.waitForDeployment();

    const DexCalc = await ethers.getContractFactory('DexCalc');
    const dexCalc = await DexCalc.connect(admin).deploy();
    await dexCalc.waitForDeployment();

    const Token = await ethers.getContractFactory('Token');
    const tokenA = await Token.connect(admin).deploy(
      'tokenA',
      'ABC',
      '1000000000',
    );
    await tokenA.waitForDeployment();
    const tokenB = await Token.connect(admin).deploy(
      'tokenB',
      'DEF',
      '1000000000',
    );
    await tokenB.waitForDeployment();

    return { factory, dexCalc, tokenA, tokenB };
  }

  describe('Run contract', function () {
    it('Should equal pair address to calculated pair address', async function () {
      const { dexCalc, factory, tokenA, tokenB } =
        await loadFixture(deployContracts);

      const TOKEN_A_ADDRESS = await tokenA.getAddress();
      const TOKEN_B_ADDRESS = await tokenB.getAddress();

      await expect(factory.createPair(TOKEN_A_ADDRESS, TOKEN_B_ADDRESS)).not.to
        .be.reverted;

      // pair
      const PAIR_ADDRESS = await factory.getPair(
        TOKEN_A_ADDRESS,
        TOKEN_B_ADDRESS,
      );
      // calculated pair
      const FACTORY_ADDRESS = await factory.getAddress();
      const CALCULATED_PAIR_ADDRESS = await dexCalc.calcPair(
        FACTORY_ADDRESS,
        TOKEN_A_ADDRESS,
        TOKEN_B_ADDRESS,
      );
      expect(PAIR_ADDRESS).to.equal(CALCULATED_PAIR_ADDRESS);
    });
  });
});
