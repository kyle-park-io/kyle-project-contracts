import fs from 'fs';

export default class FileReader {
  cwd = process.cwd();

  public async getAbi(contractName: string): Promise<any[]> {
    try {
      const jsonInterface = JSON.parse(
        await fs.promises.readFile(
          `${this.cwd}/artifacts/${contractName}.json`,
          'utf8',
        ),
      );
      const abi = jsonInterface.abi;
      return abi;
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  public async getBytecode(contractName: string): Promise<string> {
    try {
      const jsonInterface = JSON.parse(
        await fs.promises.readFile(
          `${this.cwd}/artifacts/${contractName}.json`,
          'utf8',
        ),
      );
      const bytecode = jsonInterface.bytecode;
      return bytecode;
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  public async getContractAddress(contractName: string): Promise<string> {
    try {
      const contract = await fs.promises.readFile(
        `${this.cwd}/contracts/${contractName}.contract.json`,
        'utf8',
      );
      const parsedContract = JSON.parse(contract);
      const contractAddress = parsedContract.contractAddress;
      return contractAddress;
    } catch (err) {
      console.error(err);
      throw err;
    }
  }
}
