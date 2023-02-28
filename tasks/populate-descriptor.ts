import { task } from "hardhat/config";
import ImageData from "../files/image-data.json";
import { dataToDescriptorInput } from "./utils";

enum TraitType {
  Special,
  Background,
  Body,
  Pants,
  Shoes,
  Shirts,
  Beards,
  Heads,
  Eyes,
  Accessories,
}

task(
  "populate-descriptor",
  "Populates the descriptor with color palettes and Smol Joe parts"
).setAction(async ({}, { ethers, deployments, getNamedAccounts }) => {
  const { deployer } = await getNamedAccounts();

  const descriptorFactory = await ethers.getContractFactory(
    "SmolJoeDescriptor"
  );

  const descriptor = descriptorFactory.attach(
    (await deployments.get("SmolJoeDescriptor")).address
  );

  const { palette, images } = ImageData;
  let {
    backgrounds,
    bodies,
    pants,
    shoes,
    shirts,
    beards,
    heads,
    eyes,
    accessories,
  } = images;

  const backgroundsPage = dataToDescriptorInput(
    backgrounds.map(({ data }) => data),
    backgrounds.map(({ filename }) => filename)
  );
  const bodiesPage = dataToDescriptorInput(
    bodies.map(({ data }) => data),
    bodies.map(({ filename }) => filename)
  );
  const pantsPage = dataToDescriptorInput(
    pants.map(({ data }) => data),
    pants.map(({ filename }) => filename)
  );
  const shoesPage = dataToDescriptorInput(
    shoes.map(({ data }) => data),
    shoes.map(({ filename }) => filename)
  );
  const shirtsPage = dataToDescriptorInput(
    shirts.map(({ data }) => data),
    shirts.map(({ filename }) => filename)
  );
  const beardsPage = dataToDescriptorInput(
    beards.map(({ data }) => data),
    beards.map(({ filename }) => filename)
  );
  const headsPage = dataToDescriptorInput(
    heads.map(({ data }) => data),
    heads.map(({ filename }) => filename)
  );
  const eyesPage = dataToDescriptorInput(
    eyes.map(({ data }) => data),
    eyes.map(({ filename }) => filename)
  );
  const accessoriesPage = dataToDescriptorInput(
    accessories.map(({ data }) => data),
    accessories.map(({ filename }) => filename)
  );

  const balanceBefore = await ethers.provider.getBalance(deployer);

  const txPalette = await descriptor.setPalette(
    0,
    `0x000000${palette.join("")}`
  );
  await txPalette.wait();

  const txBackgrounds = await descriptor.addTraits(
    TraitType.Background,
    backgroundsPage.encodedCompressed,
    backgroundsPage.originalLength,
    backgroundsPage.itemCount
  );
  await txBackgrounds.wait();

  const txBodies = await descriptor.addTraits(
    TraitType.Body,
    bodiesPage.encodedCompressed,
    bodiesPage.originalLength,
    bodiesPage.itemCount
  );
  await txBodies.wait();

  const txPants = await descriptor.addTraits(
    TraitType.Pants,
    pantsPage.encodedCompressed,
    pantsPage.originalLength,
    pantsPage.itemCount
  );
  await txPants.wait();

  const txShoes = await descriptor.addTraits(
    TraitType.Shoes,
    shoesPage.encodedCompressed,
    shoesPage.originalLength,
    shoesPage.itemCount
  );
  await txShoes.wait();

  const txShirts = await descriptor.addTraits(
    TraitType.Shirts,
    shirtsPage.encodedCompressed,
    shirtsPage.originalLength,
    shirtsPage.itemCount
  );
  await txShirts.wait();

  const txBeards = await descriptor.addTraits(
    TraitType.Beards,
    beardsPage.encodedCompressed,
    beardsPage.originalLength,
    beardsPage.itemCount
  );
  await txBeards.wait();

  const txHeads = await descriptor.addTraits(
    TraitType.Heads,
    headsPage.encodedCompressed,
    headsPage.originalLength,
    headsPage.itemCount
  );
  await txHeads.wait();

  const txEyes = await descriptor.addTraits(
    TraitType.Eyes,
    eyesPage.encodedCompressed,
    eyesPage.originalLength,
    eyesPage.itemCount
  );
  await txEyes.wait();

  const txAccessories = await descriptor.addTraits(
    TraitType.Accessories,
    accessoriesPage.encodedCompressed,
    accessoriesPage.originalLength,
    accessoriesPage.itemCount
  );
  await txAccessories.wait();

  console.log(
    "Backgrounds added: ",
    await descriptor.traitCount(TraitType.Background)
  );
  console.log("Bodies added: ", await descriptor.traitCount(TraitType.Body));
  console.log("Pants added: ", await descriptor.traitCount(TraitType.Pants));
  console.log("Shoes added: ", await descriptor.traitCount(TraitType.Shoes));
  console.log("Shirts added: ", await descriptor.traitCount(TraitType.Shirts));
  console.log("Beards added: ", await descriptor.traitCount(TraitType.Beards));
  console.log("Heads added: ", await descriptor.traitCount(TraitType.Heads));
  console.log("Eyes added: ", await descriptor.traitCount(TraitType.Eyes));
  console.log(
    "Accessories added: ",
    await descriptor.traitCount(TraitType.Accessories)
  );

  const gasPaid = balanceBefore.sub(await ethers.provider.getBalance(deployer));
  console.log("Gas paid: ", ethers.utils.formatEther(gasPaid));
});
