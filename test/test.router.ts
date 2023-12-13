import { ethers } from 'hardhat';
import { type Token, type Factory, type Router } from 'typechain-types';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { type HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { expect } from 'chai';
import { setTimeout } from 'timers/promises';

describe('Test', function () {
  describe('Run contract', function () {
    describe('Add liquitidy', function () {
      it('should get liquidity', async function () {
        const [admin] = await loadFixture(init);
        const { factory, router, tokenA, tokenB, tokenC } =
          await loadFixture(deployDexContracts);

        const Pair = await ethers.getContractFactory('Pair');
        const { TOKEN_A_ADDRESS, TOKEN_B_ADDRESS, PAIR_AB_ADDRESS } =
          await setContracts(factory, router, tokenA, tokenB, tokenC);
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
  });
});

async function init(): Promise<HardhatEthersSigner[]> {
  const [admin, user1] = await ethers.getSigners();
  return [admin, user1];
}

async function deployDexContracts(): Promise<{
  factory: Factory;
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

  const Router = await ethers.getContractFactory('Router');
  const router = await Router.connect(admin).deploy(FACTORY_ADDRESS);
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

  return { factory, router, tokenA, tokenB, tokenC };
}

async function setContracts(
  factory: Factory,
  router: Router,
  tokenA?: Token,
  tokenB?: Token,
  tokenC?: Token,
  tokenD?: Token,
): Promise<{
  TOKEN_A_ADDRESS: string;
  TOKEN_B_ADDRESS: string;
  TOKEN_C_ADDRESS: string;
  PAIR_AB_ADDRESS: string;
  PAIR_BC_ADDRESS: string;
  PAIR_AC_ADDRESS: string;
}> {
  // get address
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
  return {
    TOKEN_A_ADDRESS,
    TOKEN_B_ADDRESS,
    TOKEN_C_ADDRESS,
    PAIR_AB_ADDRESS,
    PAIR_BC_ADDRESS,
    PAIR_AC_ADDRESS,
  };
}
