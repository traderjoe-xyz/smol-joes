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

  const txBackgrounds = await descriptor.addManyBackgrounds(bgcolors);
  await txBackgrounds.wait();

  const txPalette = await descriptor.setPalette(
    0,
    `0x000000${palette.join("")}`
  );
  await txPalette.wait();

  const txBodies = await descriptor.addBodies(
    bodiesPage.encodedCompressed,
    bodiesPage.originalLength,
    bodiesPage.itemCount
  );
  await txBodies.wait();

  const txPants = await descriptor.addPants(
    pantsPage.encodedCompressed,
    pantsPage.originalLength,
    pantsPage.itemCount
  );
  await txPants.wait();

  const txShoes = await descriptor.addShoes(
    shoesPage.encodedCompressed,
    shoesPage.originalLength,
    shoesPage.itemCount
  );
  await txShoes.wait();

  const txShirts = await descriptor.addShirts(
    shirtsPage.encodedCompressed,
    shirtsPage.originalLength,
    shirtsPage.itemCount
  );
  await txShirts.wait();

  const txBeards = await descriptor.addBeards(
    beardsPage.encodedCompressed,
    beardsPage.originalLength,
    beardsPage.itemCount
  );
  await txBeards.wait();

  const txHeads = await descriptor.addHeads(
    headsPage.encodedCompressed,
    headsPage.originalLength,
    headsPage.itemCount
  );
  await txHeads.wait();

  const txEyes = await descriptor.addEyes(
    eyesPage.encodedCompressed,
    eyesPage.originalLength,
    eyesPage.itemCount
  );
  await txEyes.wait();

  const txAccessories = await descriptor.addAccessories(
    accessoriesPage.encodedCompressed,
    accessoriesPage.originalLength,
    accessoriesPage.itemCount
  );
  await txAccessories.wait();

  console.log("Backgrounds added: ", await descriptor.backgroundCount());
  console.log("Bodies added: ", await descriptor.bodyCount());
  console.log("Pants added: ", await descriptor.pantCount());
  console.log("Shoes added: ", await descriptor.shoeCount());
  console.log("Shirts added: ", await descriptor.shirtCount());
  console.log("Beards added: ", await descriptor.beardCount());
  console.log("Heads added: ", await descriptor.headCount());
  console.log("Eyes added: ", await descriptor.eyeCount());
  console.log("Accessories added: ", await descriptor.accessoryCount());
});
