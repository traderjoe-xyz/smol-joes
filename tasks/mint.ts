import { task, types } from "hardhat/config";

task("mint", "Mints a smol joe token")
  .addOptionalParam("tokenId", "The token ID to be minted", 0, types.int)
  .setAction(async ({ tokenId }, { ethers, deployments }) => {
    const tokenFactory = await ethers.getContractFactory("SmolJoes");

    const token = tokenFactory.attach(
      (await deployments.get("SmolJoes")).address
    );

    await token.mint(tokenId);
    await token.mint(tokenId + 1);
    await token.mint(tokenId + 2);
    await token.mint(tokenId + 3);
    await token.mint(tokenId + 4);

    console.log(`Minted token with ID ${tokenId}`);
  });
