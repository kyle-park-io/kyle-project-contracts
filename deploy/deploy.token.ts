import { ethers } from 'hardhat';
import fs from 'fs';
import { setTimeout } from 'timers/promises';

async function main(): Promise<void> {
  void deploy('tokenA', 'ABC', '100000000');
  await setTimeout(3000);
  void deploy('tokenB', 'DEF', '100000000');
}

async function deploy(name, symbol, totalSupply): Promise<void> {
  try {
    const Token = await ethers.getContractFactory('Token');
    const token = await Token.deploy(name, symbol, totalSupply);
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();
    const deployer = await ethers.getSigners();
    console.log(`deployed to ${tokenAddress}`);
    const result = {
      deployer: deployer[0].address,
      contract: name,
      contractAddress: tokenAddress,
    };
    const jsonString = JSON.stringify(result);
    await fs.promises.writeFile(`config/${name}.contract.json`, jsonString);
  } catch (err) {
    console.error(err);
  }
}

void main();
