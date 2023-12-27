#!/bin/sh

# init
npx ts-node src/init.ts &

./scripts/deploy.sh

wait
