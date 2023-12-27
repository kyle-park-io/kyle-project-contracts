## prod stage
# node version
FROM node:16-slim

# install git
RUN apt-get update && apt-get install -y git \
  vim

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

# # run deploy script
COPY scripts ./scripts
# RUN chmod +x scripts/deploy.sh && ./scripts/deploy.sh

# # run server
RUN chmod +x scripts/init.sh
ENTRYPOINT ["scripts/init.sh"]
