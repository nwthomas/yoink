### NOTE: This contract is unaudited. If you use this, you do so at your own risk.

<div>
    <h1 style="width:100%;text-align:center;">YOINK ⛏</h1>
</div>

## TABLE OF CONTENTS

- [Description](#description)
- [Getting Started](#getting-started)
- [Technology Stack](#technology-stack)
- [Testing](#testing)
- [Acknowledgements](#acknowledgements)

## DESCRIPTION

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

- Huge thanks to my capstone project team in my code bootcamp for starting me down the Web3 and Solidity path
- Thank you to Twitter for building a version of profile pictures that I got FOMO over
