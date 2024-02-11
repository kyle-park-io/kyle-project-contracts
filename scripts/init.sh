#!/bin/sh

# init
npx ts-node src/init.ts &

# deploy
./scripts/deploy.sh

# run
./scripts/dev/distributeToken.sh
./scripts/dev/factory.sh
./scripts/dev/dex.sh

wait
