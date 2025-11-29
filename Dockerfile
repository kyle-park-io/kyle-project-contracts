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

# copy package.json
COPY package*.json ./

# copy tsconfig.json
COPY tsconfig.json ./

# copy hardhat.config.ts
COPY hardhat.config.ts ./

# install dependency
RUN npm install

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
