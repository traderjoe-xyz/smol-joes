import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, run } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();
  const descriptor = (await deployments.get("SmolJoeDescriptor")).address;
  const inflator = (await deployments.get("Inflator")).address;

  const deployResult = await deploy("SmolJoeArt", {
    from: deployer,
    args: [descriptor, inflator],
    log: true,
    autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
  });

  if (deployResult.newlyDeployed) {
    const contract = await hre.ethers.getContractAt(
      "SmolJoeDescriptor",
      descriptor
    );
    await contract.setArt(deployResult.address);
  }

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
func.tags = ["SmolJoeArt"];
func.dependencies = ["SmolJoeDescriptor", "Inflator"];
