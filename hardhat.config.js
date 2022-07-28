require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { ALCHEMY, PRIVATE_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.14",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    artifacts: "./artifacts",
  },
  defaultNetwork: "mumbai",
  networks: {
    mumbai: {
      url: ALCHEMY,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
};
