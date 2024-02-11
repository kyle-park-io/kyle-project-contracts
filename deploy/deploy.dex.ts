import { ethers } from 'hardhat';
import fs from 'fs';
import { setTimeout } from 'timers/promises';

async function main(): Promise<void> {
  void deploy();
}

async function deploy(): Promise<void> {
  try {
    // deployer
    const deployer = await ethers.getSigners();
    const admin = deployer[0];

    // util
    const DexCalc = await ethers.getContractFactory('DexCalc');
    const dexCalc = await DexCalc.connect(admin).deploy();
    await dexCalc.waitForDeployment();
    const DEXCALC_ADDRESS = await dexCalc.getAddress();
    console.log(`deployed to ${DEXCALC_ADDRESS}`);
    let result = {
      deployer: deployer[0].address,
      contract: 'DexCalc',
      contractAddress: DEXCALC_ADDRESS,
    };
    let jsonString = JSON.stringify(result);
    await fs.promises.writeFile(`config/DexCalc.contract.json`, jsonString);

    // factory
    const Factory = await ethers.getContractFactory('Factory');
    const factory = await Factory.connect(admin).deploy(admin.address);
    await factory.waitForDeployment();
    const FACTORY_ADDRESS = await factory.getAddress();
    console.log(`deployed to ${FACTORY_ADDRESS}`);
    result = {
      deployer: deployer[0].address,
      contract: 'Factory',
      contractAddress: FACTORY_ADDRESS,
    };
    jsonString = JSON.stringify(result);
    await fs.promises.writeFile(`config/Factory.contract.json`, jsonString);

    // weth
    const WETH = await ethers.getContractFactory('WETH');
    const weth = await WETH.connect(admin).deploy();
    await weth.waitForDeployment();
    const WETH_ADDRESS = await weth.getAddress();
    console.log(`deployed to ${WETH_ADDRESS}`);
    result = {
      deployer: deployer[0].address,
      contract: 'WETH',
      contractAddress: WETH_ADDRESS,
    };
    jsonString = JSON.stringify(result);
    await fs.promises.writeFile(`config/WETH.contract.json`, jsonString);

    // router
    const Router = await ethers.getContractFactory('Router');
    const router = await Router.connect(admin).deploy(
      FACTORY_ADDRESS,
      WETH_ADDRESS,
    );
    await router.waitForDeployment();
    const ROUTER_ADDRESS = await router.getAddress();
    console.log(`deployed to ${ROUTER_ADDRESS}`);
    result = {
      deployer: deployer[0].address,
      contract: 'Router',
      contractAddress: ROUTER_ADDRESS,
    };
    jsonString = JSON.stringify(result);
    await fs.promises.writeFile(`config/Router.contract.json`, jsonString);
  } catch (err) {
    console.error(err);
  }
}

void main();
