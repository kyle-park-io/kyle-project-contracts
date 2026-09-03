// import { Client } from 'ssh2';
import { spawn } from 'child_process';
import * as dotenv from 'dotenv';
import fs from 'fs-extra';

// accounts.ts reads process.env at module load, and hardhat.config.ts loads the
// file for its own copy. This process gets it too, otherwise every key here is
// undefined.
dotenv.config();

import { userConfig } from './accounts';

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

// exec set utf8 on the streams for us, so `data` arrived as a string. spawn
// hands over Buffers unless asked, and the regexes below want text.
hardhatNode.stdout.setEncoding('utf8');
hardhatNode.stderr.setEncoding('utf8');

hardhatNode.stdout.on('data', (data) => {
  const accountRegex = /Account #(\d+): (0x[a-fA-F0-9]{40}) \((.+)\)/g;

  let match;
  while ((match = accountRegex.exec(data)) !== null) {
    accounts.push(match[2]);
  }

  // Two things were read out of this stream that should not have been.
  //
  // `=== 20` depended on where the stream happened to split: hardhat prints
  // twenty accounts, and a chunk carrying the nineteenth and twentieth together
  // stepped from 19 to 21, so the file was never written.
  //
  // The private keys were scraped from the same output, but hardhat only prints
  // those for accounts it generated itself. These come from config, so it
  // prints the addresses alone and the scrape found nothing — which is why
  // accounts.json stopped being written. They are already in userConfig, the
  // very list hardhat was handed, so they are read from there instead. Nothing
  // downstream reads the field either: the dev scripts take index and address.
  if (accounts.length >= 6 && resultArray.length === 0) {
    // for (let i = 1; i < accounts.length; i++) {
    for (let i = 1; i <= 5; i++) {
      const configured = userConfig[i];
      const result: Result = {
        index: i,
        address: accounts[i],
        privateKey:
          typeof configured === 'object' && 'privateKey' in configured
            ? configured.privateKey
            : '',
      };
      resultArray.push(result);
    }

    accounts.length = 0;

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
