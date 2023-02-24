import "dotenv/config";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "./tasks";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10_000,
      },
    },
  },
  networks: {
    hardhat: {
      blockGasLimit: 200_000_000,
      accounts: {
        count: 2,
      },
    },
    fuji: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      gasPrice: 28_000_000_000,
      chainId: 43113,
      accounts: process.env.DEPLOY_PRIVATE_KEY
        ? [process.env.DEPLOY_PRIVATE_KEY]
        : [],
      saveDeployments: true,
    },
    avalanche: {
      url: "https://api.avax.network/ext/bc/C/rpc",
      gasPrice: 28_000_000_000,
      chainId: 43114,
      accounts: process.env.DEPLOY_PRIVATE_KEY
        ? [process.env.DEPLOY_PRIVATE_KEY]
        : [],
    },
  },
  etherscan: {
    apiKey: {
      avalanche: process.env.SNOWTRACE_API_KEY || "",
      avalancheFujiTestnet: process.env.SNOWTRACE_API_KEY || "",
    },
  },
  namedAccounts: {
    deployer: 0,
  },
};

export default config;
