require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require("hardhat-interface-generator");
require('dotenv').config();
require("@nomiclabs/hardhat-etherscan");

const config = {
  solidity: "0.8.11",
  mocha: {
    timeout: 4000000
  },
  networks : {
    rinkeby: {
      url: `${process.env.NODE_URI_RINKEBY}`,
      chainId: 4,
      live: true,
      tags: ["staging"],
      saveDeployments: true,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`]
    },
    mainnet: {
      url: `${process.env.NODE_URI_MAINNET}`,
      chainId: 1,
      live: true,
      tags: ["production"],
      saveDeployments: true,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`]
    }
  },
  namedAccounts: {
    deployer: {
        default: 0, 
        localhost: `${process.env.DEPLOYER_ACCOUNT_ADDRESS}`,
        ropsten: `${process.env.DEPLOYER_ACCOUNT_ADDRESS}`,
        rinkeby: `${process.env.DEPLOYER_ACCOUNT_ADDRESS}`
    }     
  },
  etherscan: {
    apiKey: `${process.env.ETHERSCAN_API}`
  }
};

module.exports = config;


