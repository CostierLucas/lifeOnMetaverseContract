require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

const { ALCHEMY, PRIVATE_KEY, POLYGON_SCAN, ALCHEMY_KEY } = process.env;

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
  // defaultNetwork: "mumbai",
  networks: {
    hardhat: {
      chainId: 1337, // network config 1337 is for test for exemple mainnet ETH : 1
    },
    // mumbai: {
    //   url: ALCHEMY,
    //   accounts: [`0x${PRIVATE_KEY}`],
    // },
  },
  etherscan: {
    apiKey: POLYGON_SCAN,
  },
};
