import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, run } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const descriptor = (await deployments.get("SmolJoeDescriptor")).address;
  const seeder = (await deployments.get("SmolJoeSeeder")).address;

  const deployResult = await deploy("SmolJoes", {
    from: deployer,
    args: [descriptor, seeder],
    log: true,
    autoMine: true,
  });

  if (hre.network.name !== "hardhat") {
    try {
      await run("verify:verify", {
        address: deployResult.address,
        constructorArguments: [descriptor, seeder],
      });
    } catch (err) {
      console.error(err);
    }
  }
};

export default func;

func.tags = ["SmolJoes"];
func.dependencies = ["SmolJoeDescriptor", "SmolJoeSeeder"];
