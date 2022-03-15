### NOTE: This contract is completely unaudited. If you use this, you do so at your own risk!

# GIMME TOKEN 📸

## TABLE OF CONTENTS

- [Description](#description)
- [Getting Started](#getting-started)
- [Technology Stack](#technology-stack)
- [Testing](#testing)

## DESCRIPTION

Smart contracts for minting your own custom NFT tokens. This is incredibly useful for social media (e.g. Twitter's NFT profile pictures) as well as a variety of other use cases.

## GETTING STARTED

If you want to use these contracts locally, you'll need to be prepared to find private keys for a service like [Alchemy](https://www.alchemy.com/) or [Infura](https://infura.io/) (either on Rinkeby or Mainnet) as well as private keys for your Ethereum wallets (again, on either Rinkeby or Mainnet).

Once you run `yarn install` and put the values from the paragraph above into a `.env` file (following the example of the `.env.example` file), you should be set to run any of the commands in the `package.json` file.

## TECHNOLOGY STACK

These are the main dependencies used in this repo (_Note: This list is not complete as I've left out minor dependencies_):

- [TypeScript](https://www.typescriptlang.org/)
- [Hardhat](https://hardhat.org/)
- [Mocha](https://mochajs.org/)
- [Chai](https://www.chaijs.com/)
- [DotEnv](https://github.com/motdotla/dotenv)
- [ESLint](https://eslint.org/)
- [Nodemon](https://github.com/remy/nodemon)
- [Prettier](https://prettier.io/)
- [Solhint](https://github.com/protofire/solhint)
- [Typechain](https://github.com/dethcrypto/TypeChain)

## TESTING

A complete testing suite has been written in TypeScript utilizing [Hardhat](https://hardhat.org/), [Mocha](https://mochajs.org/), and [Chai](https://www.chaijs.com/). In addition, this repo makes use of the dependency [Hardhat Gas Reporter](https://github.com/cgewecke/hardhat-gas-reporter#readme) which will break down exactly how much gas each of the operations in the contract would cost on mainnet.

If you want to try running it, use the command `yarn test` in your terminal in the root of this repo after you have installed all dependencies with the command `yarn install`.
