import { task, types } from "hardhat/config";

task("mint", "Mints a smol joe token")
  .addOptionalParam("tokenId", "The token ID to be minted", 0, types.int)
  .setAction(async ({ tokenId }, { ethers, deployments, getNamedAccounts }) => {
    const tokenFactory = await ethers.getContractFactory("SmolJoes");

    const { deployer } = await getNamedAccounts();

    const token = tokenFactory.attach(
      (await deployments.get("SmolJoes")).address
    );

    for (let i = tokenId; i < tokenId + 10; i++) {
      await (await token.mint(deployer, i, { gasLimit: 400_000 })).wait();
      console.log(`Minted token with ID ${i}`);
    }
  });
