import { ethers } from 'hardhat';
import {
  type Factory,
  type WETH,
  type Router,
  type Token,
} from 'typechain-types';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { type HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { expect } from 'chai';
import { setTimeout } from 'timers/promises';

describe('Test', function () {
  describe('Run contract', function () {
    describe('Add liquitidy', function () {
      describe('With Token', function () {
        it('should get liquidity', async function () {
          const [admin] = await loadFixture(init);
          const { factory, weth, router, tokenA, tokenB, tokenC } =
            await loadFixture(deployDexContracts);

          const Pair = await ethers.getContractFactory('Pair');
          const { TOKEN_A_ADDRESS, TOKEN_B_ADDRESS, PAIR_AB_ADDRESS } =
            await setContracts(factory, weth, router, tokenA, tokenB, tokenC);
          const PAIR_AB_CONTRACT = new ethers.Contract(
            PAIR_AB_ADDRESS,
            Pair.interface,
            admin,
          );

          await router.addLiquidity(
            TOKEN_A_ADDRESS,
            TOKEN_B_ADDRESS,
            '1',
            '10000000',
            '0',
            '0',
            admin.address,
            1,
          );

          await router.addLiquidity(
            TOKEN_A_ADDRESS,
            TOKEN_B_ADDRESS,
            '1',
            '1000000',
            '0',
            '0',
            admin.address,
            1,
          );
        });
      });
    });
  });
});

async function init(): Promise<HardhatEthersSigner[]> {
  const [admin, user1] = await ethers.getSigners();
  return [admin, user1];
}

async function deployDexContracts(): Promise<{
  factory: Factory;
  weth: WETH;
  router: Router;
  tokenA: Token;
  tokenB: Token;
  tokenC: Token;
}> {
  const [admin] = await loadFixture(init);

  const Factory = await ethers.getContractFactory('Factory');
  const factory = await Factory.connect(admin).deploy(admin.address);
  await factory.waitForDeployment();
  const FACTORY_ADDRESS = await factory.getAddress();

  const WETH = await ethers.getContractFactory('WETH');
  const weth = await WETH.connect(admin).deploy();
  await weth.waitForDeployment();
  const WETH_ADDRESS = await weth.getAddress();

  const Router = await ethers.getContractFactory('Router');
  const router = await Router.connect(admin).deploy(
    FACTORY_ADDRESS,
    WETH_ADDRESS,
  );
  await router.waitForDeployment();

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
  const tokenC = await Token.connect(admin).deploy(
    'tokenC',
    'GHI',
    '1000000000',
  );
  await tokenC.waitForDeployment();

  return { factory, weth, router, tokenA, tokenB, tokenC };
}

async function setContracts(
  factory: Factory,
  weth: WETH,
  router: Router,
  tokenA?: Token,
  tokenB?: Token,
  tokenC?: Token,
  tokenD?: Token,
): Promise<{
  WETH_ADDRESS: string;
  ROUTER_ADDRESS: string;
  TOKEN_A_ADDRESS: string;
  TOKEN_B_ADDRESS: string;
  TOKEN_C_ADDRESS: string;
  PAIR_AB_ADDRESS: string;
  PAIR_BC_ADDRESS: string;
  PAIR_AC_ADDRESS: string;
  PAIR_AW_ADDRESS: string;
}> {
  // get address
  const WETH_ADDRESS = await weth.getAddress();
  const ROUTER_ADDRESS = await router.getAddress();
  const TOKEN_A_ADDRESS = (await tokenA?.getAddress()) as string;
  const TOKEN_B_ADDRESS = (await tokenB?.getAddress()) as string;
  const TOKEN_C_ADDRESS = (await tokenC?.getAddress()) as string;

  // set approval
  await tokenA?.approve(ROUTER_ADDRESS, ethers.parseEther('1000000000'));
  await tokenB?.approve(ROUTER_ADDRESS, ethers.parseEther('1000000000'));
  await tokenC?.approve(ROUTER_ADDRESS, ethers.parseEther('1000000000'));
  await tokenD?.approve(ROUTER_ADDRESS, ethers.parseEther('1000000000'));

  // init pair
  await factory.createPair(TOKEN_A_ADDRESS, TOKEN_B_ADDRESS);
  await factory.createPair(TOKEN_B_ADDRESS, TOKEN_C_ADDRESS);
  await factory.createPair(TOKEN_A_ADDRESS, TOKEN_C_ADDRESS);
  await factory.createPair(TOKEN_A_ADDRESS, WETH_ADDRESS);

  // set pair
  const PAIR_AB_ADDRESS = await factory.getPair(
    TOKEN_A_ADDRESS,
    TOKEN_B_ADDRESS,
  );
  const PAIR_BC_ADDRESS = await factory.getPair(
    TOKEN_B_ADDRESS,
    TOKEN_C_ADDRESS,
  );
  const PAIR_AC_ADDRESS = await factory.getPair(
    TOKEN_A_ADDRESS,
    TOKEN_C_ADDRESS,
  );
  const PAIR_AW_ADDRESS = await factory.getPair(TOKEN_A_ADDRESS, WETH_ADDRESS);

  return {
    WETH_ADDRESS,
    ROUTER_ADDRESS,
    TOKEN_A_ADDRESS,
    TOKEN_B_ADDRESS,
    TOKEN_C_ADDRESS,
    PAIR_AB_ADDRESS,
    PAIR_BC_ADDRESS,
    PAIR_AC_ADDRESS,
    PAIR_AW_ADDRESS,
  };
}
