// import { Client } from 'ssh2';
import { exec } from 'child_process';
import fs from 'fs-extra';

// const connSettings = {
//   host: 'remote-node-ip',
//   port: 22,
//   username: 'username',
//   privateKey: fs.readFileSync('/path/to/your/private/key.pem'),
// };

// const remotePath = '/path/to/remote/destination';
// const localPath = '/path/to/local/file';

// // ssh
// const conn = new Client();
// conn
//   .on('ready', () => {
//     console.log('Client :: ready');
//     conn.sftp((err, sftp) => {
//       if (err != null) throw err;

//       sftp.fastPut(localPath, remotePath, {}, (err) => {
//         if (err != null) throw err;
//         console.log(`File transferred successfully to ${remotePath}`);
//         conn.end();
//       });
//     });
//   })
//   .connect(connSettings);

interface Result {
  index: number;
  address: string;
  privateKey: string;
}

const accounts: string[] = [];
const privateKey: string[] = [];
const resultArray: Result[] = [];

// run hardhat node
const hardhatNode = exec('npx hardhat node');

if (hardhatNode.stdout === null || hardhatNode.stderr === null) {
  console.log(`process exit!`);
  process.exit();
}

hardhatNode.stdout.on('data', (data) => {
  const accountRegex = /Account #(\d+): (0x[a-fA-F0-9]{40}) \((.+)\)/g;
  const privateKeyRegex = /Private Key: (0x[a-fA-F0-9]{64})/g;

  let match;
  while ((match = privateKeyRegex.exec(data)) !== null) {
    privateKey.push(match[1]);
  }
  while ((match = accountRegex.exec(data)) !== null) {
    accounts.push(match[2]);
  }

  if (accounts.length === 20) {
    // for (let i = 1; i < accounts.length; i++) {
    for (let i = 1; i <= 5; i++) {
      const result: Result = {
        index: i,
        address: accounts[i],
        privateKey: privateKey[i],
      };
      resultArray.push(result);
    }

    accounts.length = 0;
    privateKey.length = 0;

    const save = JSON.stringify(resultArray, undefined, 2);
    fs.writeFileSync('accounts.json', save);
    console.log('accounts info save complete!');
  }
});

hardhatNode.stderr.on('data', (data) => {
  console.error(`stderr: ${data}`);
});

hardhatNode.on('close', (code) => {
  console.log(`child process exited with code ${code}`);
});
