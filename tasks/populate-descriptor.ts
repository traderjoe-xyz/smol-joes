import { task } from "hardhat/config";
import ImageData from "../files/image-data.json";
import { dataToDescriptorInput } from "./utils";

task(
  "populate-descriptor",
  "Populates the descriptor with color palettes and Smol Joe parts"
).setAction(async ({}, { ethers, deployments }) => {
  const descriptorFactory = await ethers.getContractFactory(
    "SmolJoeDescriptor"
  );

  const descriptor = descriptorFactory.attach(
    (await deployments.get("SmolJoeDescriptor")).address
  );

  const { bgcolors, palette, images } = ImageData;
  const { bodies, heads } = images;

  const bodiesPage = dataToDescriptorInput(bodies.map(({ data }) => data));
  const headsPage = dataToDescriptorInput(heads.map(({ data }) => data));

  await descriptor.addManyBackgrounds(bgcolors);
  await descriptor.setPalette(0, `0x000000${palette.join("")}`);

  await descriptor.addBodies(
    bodiesPage.encodedCompressed,
    bodiesPage.originalLength,
    bodiesPage.itemCount
  );
  await descriptor.addHeads(
    headsPage.encodedCompressed,
    headsPage.originalLength,
    headsPage.itemCount
  );

  console.log("Descriptor populated with palettes and parts.");
});
