import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, run } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const deployResult = await deploy("Inflator", {
    from: deployer,
    args: [],
    log: true,
    autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
  });

  if (hre.network.name !== "hardhat") {
    try {
      await run("verify:verify", {
        address: deployResult.address,
      });
    } catch (err) {
      console.error(err);
    }
  }
};
export default func;
func.tags = ["Inflator"];
