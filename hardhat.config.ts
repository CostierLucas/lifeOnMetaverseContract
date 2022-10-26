import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
import "@nomicfoundation/hardhat-chai-matchers";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import { BigNumber, Contract, ethers } from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";

dotenv.config();

const { ALCHEMY, PRIVATE_KEY, POLYGON_SCAN, ALCHEMY_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.14",
    settings: {
      optimizer: {
        runs: 200,
        enabled: true,
      },
    },
  },
  paths: {
    artifacts: "./artifacts",
  },
  defaultNetwork: "mumbai",
  networks: {
    // hardhat: {
    //   forking: {
    //     url: "https://eth-mainnet.g.alchemy.com/v2/BwXumcWf-Xq04eq59w16nqM7R37brHIp",
    //   }, // network config 1337 is for test for exemple mainnet ETH : 1
    // },
    mumbai: {
      url: ALCHEMY,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  // gasReporter: {
  //   enabled: true,
  //   currency: "EUR",
  //   gasPrice: 60,
  // },
  etherscan: {
    apiKey: POLYGON_SCAN,
  },
};

export default config;
