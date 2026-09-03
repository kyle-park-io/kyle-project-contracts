## prod stage
# node version
FROM node:22-slim

# install git
RUN apt-get update && apt-get install -y git \
  vim \
  curl \
  jq \
  bc \
  bash

# set dir
WORKDIR /usr/src/app

# copy package.json and the lockfile
#
# The lockfile has to come along. Without it `npm install` resolved every
# range afresh at build time, so an image built months apart from another
# was a different set of dependencies — which is how a `typescript: "*"`
# declaration quietly picked up a major release that ts-node cannot load.
COPY package*.json yarn.lock ./

# copy tsconfig.json
COPY tsconfig.json ./

# copy hardhat.config.ts
COPY hardhat.config.ts ./

# install dependency
#
# yarn, matching the lockfile in the repo. npm was reading package.json and
# ignoring yarn.lock entirely, so the lock recorded one set of versions and
# the image shipped another. --frozen-lockfile makes a drifted lock a build
# failure rather than a surprise at runtime.
RUN yarn install --frozen-lockfile

# copy files
COPY contracts ./contracts
COPY deploy ./deploy
COPY src ./src
COPY .env ./.env
COPY tokens.json ./tokens.json

# # run deploy script
COPY scripts/prod ./scripts
# RUN chmod +x scripts/deploy.sh && ./scripts/deploy.sh
RUN chmod -R +x scripts

# # run server
RUN chmod +x scripts/init.sh
ENTRYPOINT ["scripts/init.sh"]
