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
  let { bodies, pants, shoes, shirts, beards, heads, eyes, accessories } =
    images;

  const bodiesPage = dataToDescriptorInput(bodies.map(({ data }) => data));
  const pantsPage = dataToDescriptorInput(pants.map(({ data }) => data));
  const shoesPage = dataToDescriptorInput(shoes.map(({ data }) => data));
  const shirtsPage = dataToDescriptorInput(shirts.map(({ data }) => data));
  const beardsPage = dataToDescriptorInput(beards.map(({ data }) => data));
  const headsPage = dataToDescriptorInput(heads.map(({ data }) => data));
  const eyesPage = dataToDescriptorInput(eyes.map(({ data }) => data));
  const accessoriesPage = dataToDescriptorInput(
    accessories.map(({ data }) => data)
  );

  await descriptor.addManyBackgrounds(bgcolors);
  await descriptor.setPalette(0, `0x000000${palette.join("")}`);

  await descriptor.addBodies(
    bodiesPage.encodedCompressed,
    bodiesPage.originalLength,
    bodiesPage.itemCount
  );

  await descriptor.addPants(
    pantsPage.encodedCompressed,
    pantsPage.originalLength,
    pantsPage.itemCount
  );

  await descriptor.addShoes(
    shoesPage.encodedCompressed,
    shoesPage.originalLength,
    shoesPage.itemCount
  );

  await descriptor.addShirts(
    shirtsPage.encodedCompressed,
    shirtsPage.originalLength,
    shirtsPage.itemCount
  );

  await descriptor.addBeards(
    beardsPage.encodedCompressed,
    beardsPage.originalLength,
    beardsPage.itemCount
  );

  await descriptor.addHeads(
    headsPage.encodedCompressed,
    headsPage.originalLength,
    headsPage.itemCount
  );

  await descriptor.addEyes(
    eyesPage.encodedCompressed,
    eyesPage.originalLength,
    eyesPage.itemCount
  );

  await descriptor.addAccessories(
    accessoriesPage.encodedCompressed,
    accessoriesPage.originalLength,
    accessoriesPage.itemCount
  );

  console.log("Descriptor populated with palettes and parts.");
});
