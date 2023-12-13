import { ethers } from 'hardhat';
import fs from 'fs';

async function main(): Promise<void> {
  try {
    const Basic = await ethers.getContractFactory('Basic');
    const basic = await Basic.deploy();
    await basic.waitForDeployment();
    const basicAddress = await basic.getAddress();
    const deployer = await ethers.getSigners();

    console.log(`deployed to ${basicAddress}`);
    const result = {
      deployer: deployer[0].address,
      contract: 'basic',
      contractAddress: basicAddress,
    };
    const jsonString = JSON.stringify(result);

    await fs.promises.writeFile('config/Basic.contract.json', jsonString);
  } catch (err) {
    console.error(err);
  }
}

void main();
