import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

import { HardhatUserConfig } from "hardhat/config";
import dotenv from "dotenv";

dotenv.config();

// This is a shim since TypeScript is unhappy with additional objects in the config object
type HardhatUserConfigExtended = HardhatUserConfig & { [key: string]: any };

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfigExtended = {
  solidity: "0.8.12",
  networks: {
    // mainnet: {
    //   url: process.env.MAINNET_APP_SECRET_KEY || "",
    //   accounts: [process.env.MAINNET_WALLET_PRIVATE_KEY || ""],
    // },
    rinkeby: {
      url: process.env.RINKEBY_APP_SECRET_KEY || "",
      accounts: [process.env.RINKEBY_WALLET_PRIVATE_KEY || ""],
    },
  },
  gasReporter: {
    enabled:
      Boolean(process.env.REPORT_GAS) && process.env.REPORT_GAS !== "false",
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  watcher: {
    compilation: {
      tasks: ["compile"],
      files: ["./contracts"],
      verbose: true,
    },
    ci: {
      tasks: [
        "clean",
        { command: "compile", params: { quiet: true } },
        {
          command: "test",
          params: {
            noCompile: true,
            testFiles: ["./test/EthDistributor.test.js"],
          },
        },
      ],
    },
  },
};

export default config;
