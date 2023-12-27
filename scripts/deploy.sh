#!/bin/sh

# deploy
npx hardhat compile
npx hardhat run deploy/deploy.basic.ts --network localhost
npx hardhat run deploy/deploy.token.ts --network localhost
