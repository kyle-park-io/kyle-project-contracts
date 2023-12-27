import { ethers } from 'hardhat';
import fs from 'fs';
import path from 'path';

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

    const configPath = path.resolve('config');

    if (!fs.existsSync(configPath)) {
      fs.mkdirSync(configPath, { recursive: true });
      console.log(`Folder created at: ${configPath}`);
    } else {
      console.log(`Folder already exists at: ${configPath}`);
    }

    await fs.promises.writeFile(
      `${configPath}/Basic.contract.json`,
      jsonString,
    );
  } catch (err) {
    console.error(err);
  }
}

void main();
