<div>
    <h1 style="width:100%;text-align:center;">YOINK ⛏</h1>
</div>

## TABLE OF CONTENTS

- [Description](#description)
- [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Technology Stack](#technology-stack)
- [Testing](#testing)
- [Acknowledgements](#acknowledgements)

## DESCRIPTION

> NOTE: This contract is unaudited. If you use this, you assume all responsibility.

Smart contracts for minting your own custom NFT tokens. This is incredibly useful for social media (e.g. Twitter's NFT profile pictures) as well as a variety of other use cases.

## GETTING STARTED

If you want to use these contracts locally, you'll need to be prepared to find private keys for a service like [Alchemy](https://www.alchemy.com/) or [Infura](https://infura.io/) (either on Rinkeby or Mainnet) as well as private keys for your Ethereum wallets (again, on either Rinkeby or Mainnet).

Once you run `yarn install` and put the values from the paragraph above into a `.env` file (following the example of the `.env.example` file), you should be set to run any of the commands in the `package.json` file.

The big exception is if you want to run [Slither](https://github.com/crytic/slither). In order to use this, you'll need a stable build of Python installed on your machine, run a [Pipenv shell](https://pipenv.pypa.io/en/latest/), install with `pipenv install`, and use the command `pipenv slither .`.'

For your NFT token metadata, you should follow the [Metadata Standards](https://docs.opensea.io/docs/metadata-standards) which defines the schema as:

```json
{
  "attributes": [
    {
      "trait_type": "<string>",
      "value": "<string>"
    }
  ],
  "description": "<string>",
  "image": "<string url>",
  "name": "<string>"
}
```

Here's an [example](https://www.nathanthomas.dev/nathan-token-metadata.json) for my own token.

Note that you can either feed the `mintNFT` function a URL reference to the JSON file or actually send an object as defined above due to the use of function overloading in the contract.

## DEPLOYMENT

I made the decision to setup this contract to revolve around [Frame](https://frame.sh/), a service that will allow you to deploy using your hardware wallets if you so choose.

Please go to their website and follow their setup steps. Once complete, copy the `.env.example` and fill in the following fields:

```
# Etherscan Secret Key
ETHERSCAN_API_KEY=<secret key here>

# Mainnet Secret Keys
MAINNET_APP_SECRET_KEY=<secret key here>
MAINNET_WALLET_PRIVATE_KEY=<secret key here>

# Rinkeby Secret Keys
RINKEBY_APP_SECRET_KEY=<secret key here>
RINKEBY_WALLET_PRIVATE_KEY=<secret key here>

# Testing Keys
REPORT_GAS=<boolean>
COIN_MARKET_CAP_API_KEY=<secret key here>
```

The `MAINNET_APP_SECRET_KEY` and `RINKEBY_APP_SECRET_KEY` are what you would get from a service like Infura or Alchemy.

The `MAINNET_WALLET_PRIVATE_KEY` and `RINKEBY_WALLET_PRIVATE_KEY` are what you would get from MetaMask, although mainnet is actually set up for Frame in this repo at the moment. You can revert those changes in a few short steps and mimic the Rinkeby setup in `hardhat.config.ts` for Mainnet if you'd rather just use MetaMask to deploy instead of Frame.

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
- [Slither](https://github.com/crytic/slither)

## TESTING

A complete testing suite has been written in TypeScript utilizing [Hardhat](https://hardhat.org/), [Mocha](https://mochajs.org/), and [Chai](https://www.chaijs.com/). In addition, this repo makes use of the dependency [Hardhat Gas Reporter](https://github.com/cgewecke/hardhat-gas-reporter#readme) which will break down exactly how much gas each of the operations in the contract would cost on mainnet.

If you want to try running it, use the command `yarn test` in your terminal in the root of this repo after you have installed all dependencies with the command `yarn install`.

## ACKNOWLEDGEMENTS

- Thanks to my capstone project team in my code bootcamp for starting me down the Web3 and Solidity path
- Thank you to Twitter for building a version of profile pictures that I got FOMO over
