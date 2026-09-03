// import { Client } from 'ssh2';
import { spawn } from 'child_process';
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
//
// `spawn`, not `exec`. exec buffers the child's stdout in memory and kills the
// child once it passes maxBuffer (1 MB by default), which is what had been
// happening here: the dex backend's listeners poll the RPC, hardhat logs a line
// per call, and roughly every hundred minutes the buffer filled and node
// terminated the child. `close` then fired with a null code — the signature of a
// signal — the `wait` in scripts/init.sh returned, and the container exited 0.
// Kubernetes read that as Completed and restarted it, ~14 times a day, each
// restart leaving another containerd snapshot behind on the node.
//
// This code already consumes stdout as a stream, so nothing needs exec's
// buffering. spawn streams without accumulating.
const hardhatNode = spawn('npx', ['hardhat', 'node'], { shell: true });

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

// A signal is reported separately from an exit code: a child killed by one exits
// with a null code, so logging the code alone said nothing about why it died.
hardhatNode.on('close', (code, signal) => {
  console.log(`child process exited with code ${code} signal ${signal}`);
});

// Without this, a spawn failure surfaced only as the process quietly ending.
hardhatNode.on('error', (err) => {
  console.error(`hardhat node failed: ${err.message}`);
  process.exitCode = 1;
});
