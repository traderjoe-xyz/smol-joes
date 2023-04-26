import "dotenv/config";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "./tasks";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.13",
  },
};

export default config;
