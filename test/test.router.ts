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
        it.skip('should get liquidity', async function () {
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

          let i = 1;
          while (true) {
            if (i === 4) {
              break;
            }
            console.log('PHASE ' + i);
            if (i % 2 === 1) {
              try {
                await router.addLiquidity(
                  TOKEN_A_ADDRESS,
                  TOKEN_B_ADDRESS,
                  '2000',
                  '1000',
                  '0',
                  '0',
                  admin.address,
                  1,
                );
              } catch (err) {
                console.log(err);
                break;
              }
            } else {
              try {
                await router.addLiquidity(
                  TOKEN_A_ADDRESS,
                  TOKEN_B_ADDRESS,
                  '1000',
                  '2000',
                  '0',
                  '0',
                  admin.address,
                  1,
                );
              } catch (err) {
                console.log(err);
                break;
              }
            }
            console.log("after : pair's totalsupply");
            const balance = await PAIR_AB_CONTRACT.totalSupply();
            console.log(balance);
            i++;
            await setTimeout(3000);
          }
        });
      });

      describe('With WETH', function () {
        it.skip('should get liquidity', async function () {
          const [admin] = await loadFixture(init);
          const { factory, weth, router, tokenA, tokenB, tokenC } =
            await loadFixture(deployDexContracts);

          const Pair = await ethers.getContractFactory('Pair');
          const { WETH_ADDRESS, TOKEN_A_ADDRESS, PAIR_AW_ADDRESS } =
            await setContracts(factory, weth, router, tokenA, tokenB, tokenC);
          const PAIR_AW_CONTRACT = new ethers.Contract(
            PAIR_AW_ADDRESS,
            Pair.interface,
            admin,
          );

          let i = 1;
          while (true) {
            if (i === 4) {
              break;
            }
            console.log('PHASE ' + i);
            try {
              await router.addLiquidityETH(
                TOKEN_A_ADDRESS,
                '100',
                '0',
                '0',
                admin.address,
                1,
                { value: ethers.parseEther('1') },
              );
            } catch (err) {
              console.log(err);
              break;
            }
            console.log("after : pair's totalsupply");
            const balance = await PAIR_AW_CONTRACT.totalSupply();
            console.log(balance);
            i++;
            await setTimeout(3000);
          }
        });
      });
    });

    describe('Remove liquitidy', function () {
      describe('With Token', function () {
        it('should get liquidity', async function () {
          const [admin] = await loadFixture(init);
          const { factory, weth, router, tokenA, tokenB, tokenC } =
            await loadFixture(deployDexContracts);

          const Pair = await ethers.getContractFactory('Pair');
          const {
            ROUTER_ADDRESS,
            TOKEN_A_ADDRESS,
            TOKEN_B_ADDRESS,
            PAIR_AB_ADDRESS,
          } = await setContracts(factory, weth, router, tokenA, tokenB, tokenC);
          const PAIR_AB_CONTRACT = new ethers.Contract(
            PAIR_AB_ADDRESS,
            Pair.interface,
            admin,
          );

          // PHASE0: add liquidity
          console.log('PHASE0: add liquidity');
          await router.addLiquidity(
            TOKEN_A_ADDRESS,
            TOKEN_B_ADDRESS,
            '2000',
            '1000',
            '0',
            '0',
            admin.address,
            1,
          );
          console.log("after : pair's totalsupply");
          let balance = await PAIR_AB_CONTRACT.totalSupply();
          console.log(balance);
          await setTimeout(3000);

          // PHASE1: remove liquidity
          // set allowance pair(liquidity) balance to router (user -> router)
          await PAIR_AB_CONTRACT.approve(
            ROUTER_ADDRESS,
            ethers.parseEther('1000000000'),
          );

          console.log('PHASE1: remove liquidity');
          await router.removeLiquidity(
            TOKEN_A_ADDRESS,
            TOKEN_B_ADDRESS,
            '100',
            '0',
            '0',
            admin.address,
            1,
          );
          console.log("after : pair's totalsupply");
          balance = await PAIR_AB_CONTRACT.totalSupply();
          console.log(balance);
        });
      });

      describe('With WETH', function () {
        it('should get liquidity', async function () {
          const [admin] = await loadFixture(init);
          const { factory, weth, router, tokenA, tokenB, tokenC } =
            await loadFixture(deployDexContracts);

          const Pair = await ethers.getContractFactory('Pair');
          const {
            WETH_ADDRESS,
            ROUTER_ADDRESS,
            TOKEN_A_ADDRESS,
            PAIR_AW_ADDRESS,
          } = await setContracts(factory, weth, router, tokenA, tokenB, tokenC);
          const PAIR_AW_CONTRACT = new ethers.Contract(
            PAIR_AW_ADDRESS,
            Pair.interface,
            admin,
          );

          // PHASE0: add liquidity
          console.log('PHASE0: add liquidity with eth');
          await router.addLiquidityETH(
            TOKEN_A_ADDRESS,
            '100',
            '0',
            '0',
            admin.address,
            1,
            { value: ethers.parseEther('1') },
          );
          console.log("after : pair's totalsupply");
          let balance = await PAIR_AW_CONTRACT.totalSupply();
          console.log(balance);
          await setTimeout(3000);

          // PHASE1: remove liquidity
          // set allowance pair(liquidity) balance to router (user -> router)
          await PAIR_AW_CONTRACT.approve(
            ROUTER_ADDRESS,
            ethers.parseEther('1000000000'),
          );

          console.log('PHASE1: remove liquidity with eth');
          await router.removeLiquidityETH(
            TOKEN_A_ADDRESS,
            '100000000',
            '0',
            '0',
            admin.address,
            1,
          );
          console.log("after : pair's totalsupply");
          balance = await PAIR_AW_CONTRACT.totalSupply();
          console.log(balance);
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
