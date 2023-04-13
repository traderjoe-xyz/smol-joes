import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, run, ethers } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const renderer = (await deployments.get("SVGRenderer")).address;

  // Art address will be updated in the Art deploy script
  const deployResult = await deploy("SmolJoeDescriptor", {
    from: deployer,
    args: ["0x0000000000000000000000000000000000000001", renderer],
    log: true,
    autoMine: true,
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

func.tags = ["SmolJoeDescriptor"];
func.dependencies = ["SVGRenderer"];
