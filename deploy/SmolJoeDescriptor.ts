import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, run, ethers } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();
  const renderer = (await deployments.get("SVGRenderer")).address;

  const deployResult = await deploy("SmolJoeDescriptor", {
    from: deployer,
    args: [ethers.constants.AddressZero, renderer],
    log: true,
    autoMine: true,
  });

  // if (hre.network.name !== "hardhat") {
  //   try {
  //     await run("verify:verify", {
  //       address: deployResult.address,
  //     });
  //   } catch (err) {
  //     console.error(err);
  //   }
  // }
};
export default func;
func.tags = ["SmolJoeDescriptor"];
func.dependencies = ["SVGRenderer"];
