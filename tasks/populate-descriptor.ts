import { task } from "hardhat/config";
import ImageData from "../files/assets-data/image-data.json";
import { dataToDescriptorInput } from "./utils";

enum Brotherhood {
  None,
  Academics,
  Athletes,
  Creatives,
  Gentlemans,
  MagicalBeings,
  Military,
  Musicians,
  Outlaws,
  Religious,
  Superheros,
}

enum TraitType {
  Original,
  Luminary,
  Background,
  Body,
  Pants,
  Shoes,
  Shirt,
  Beard,
  HairCapHead,
  EyeAccessory,
  Accessories,
}

interface AddMultipleTraitsData {
  traitTypes: TraitType[];
  brotherhoods: Brotherhood[];
  encodedCompressedData: string[];
  originalLengths: number[];
  itemCounts: number[];
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

  const seederFactory = await ethers.getContractFactory("SmolJoeSeeder");

  const seeder = seederFactory.attach(
    (await deployments.get("SmolJoeSeeder")).address
  );
  const { palette, images } = ImageData;

  let {
    background,
    body,
    shoes,
    pants,
    shirt,
    beard,
    hair_cap_head,
    eye_accessory,
    accessories,
    luminaries,
    originals,
  } = images;

  const emptyData: AddMultipleTraitsData = {
    traitTypes: [],
    brotherhoods: [],
    encodedCompressedData: [],
    originalLengths: [],
    itemCounts: [],
  };

  const balanceBefore = await ethers.provider.getBalance(deployer);
  // Create a list of all bodyparts
  const bodyparts = [
    {
      object: originals,
      name: "originals",
    },
    {
      object: luminaries,
      name: "luminaries",
    },
    {
      object: background,
      name: "backgrounds",
    },
    {
      object: body,
      name: "bodies",
    },
    {
      object: shoes,
      name: "shoes",
    },
    {
      object: pants,
      name: "pants",
    },
    {
      object: shirt,
      name: "shirts",
    },
    {
      object: beard,
      name: "beards",
    },
    {
      object: hair_cap_head,
      name: "heads",
    },
    {
      object: eye_accessory,
      name: "eyes",
    },
    {
      object: accessories,
      name: "accessories",
    },
  ];

  for (let i = 0; i < Object.keys(Brotherhood).length; i++) {
    const brotherhood = Object.keys(Brotherhood)[i];

    for (let j = 0; j < bodyparts.length; j++) {
      const bodypart = bodyparts[j];

      const brotherhoodBodyparts = bodypart.object.filter(
        (item) =>
          item.brotherhood ===
          (brotherhood === "MagicalBeings" ? "Magical Beings" : brotherhood)
      );

      if (brotherhoodBodyparts.length > 0) {
        if (bodypart.name === "originals") {
          const bodypartsPage = dataToDescriptorInput(
            brotherhoodBodyparts
              .filter((_, index) => index < 50)
              .map(({ data }) => data),
            brotherhoodBodyparts
              .filter((_, index) => index < 50)
              .map(({ filename }) => filename)
          );

          const tx = await descriptor.addTraits(
            j,
            Brotherhood[brotherhood],
            bodypartsPage.encodedCompressed,
            bodypartsPage.originalLength,
            bodypartsPage.itemCount
          );
          await tx.wait();

          const bodypartsPage_2 = dataToDescriptorInput(
            brotherhoodBodyparts
              .filter((_, index) => index >= 50)
              .map(({ data }) => data),
            brotherhoodBodyparts
              .filter((_, index) => index >= 50)
              .map(({ filename }) => filename)
          );

          const tx_2 = await descriptor.addTraits(
            j,
            Brotherhood[brotherhood],
            bodypartsPage_2.encodedCompressed,
            bodypartsPage_2.originalLength,
            bodypartsPage_2.itemCount
          );
          await tx_2.wait();
        } else {
          const bodypartsPage = dataToDescriptorInput(
            brotherhoodBodyparts.map(({ data }) => data),
            brotherhoodBodyparts.map(({ filename }) => filename)
          );

          const tx = await descriptor.addTraits(
            j,
            Brotherhood[brotherhood],
            bodypartsPage.encodedCompressed,
            bodypartsPage.originalLength,
            bodypartsPage.itemCount
          );
          await tx.wait();
        }

        // bodyparts[j].data.traitTypes.push(j);
        // bodyparts[j].data.brotherhoods.push(Brotherhood[brotherhood]);
        // bodyparts[j].data.encodedCompressedData.push(
        //   bodypartsPage.encodedCompressed
        // );
        // bodyparts[j].data.originalLengths.push(bodypartsPage.originalLength);
        // bodyparts[j].data.itemCounts.push(bodypartsPage.itemCount);
      }
    }
  }

  const txPalette = await descriptor.setPalette(
    0,
    `0x000000${palette.join("")}`
  );
  await txPalette.wait();

  const mappings = [
    0,
    ...Array(99)
      .fill(0)
      .map((_, i) => i + 1),
  ];

  const txMapping = await seeder.updateSpecialsArtMapping(mappings);
  await txMapping.wait();

  console.log(
    "Specials added: ",
    await descriptor.traitCount(TraitType.Original, Brotherhood.None)
  );
  console.log(
    "Uniques added: ",
    await descriptor.traitCount(TraitType.Luminary, Brotherhood.Outlaws)
  );
  console.log(
    "Backgrounds added: ",
    await descriptor.traitCount(TraitType.Background, Brotherhood.None)
  );
  console.log(
    "Bodies added: ",
    await descriptor.traitCount(TraitType.Body, Brotherhood.None)
  );
  console.log(
    "Shoes added: ",
    await descriptor.traitCount(TraitType.Shoes, Brotherhood.None)
  );
  console.log(
    "Pants added: ",
    await descriptor.traitCount(TraitType.Pants, Brotherhood.None)
  );
  console.log(
    "Shirts added: ",
    await descriptor.traitCount(TraitType.Shirt, Brotherhood.None)
  );
  console.log(
    "Beards added: ",
    await descriptor.traitCount(TraitType.Beard, Brotherhood.None)
  );
  console.log(
    "Hair Cap Head added: ",
    await descriptor.traitCount(TraitType.HairCapHead, Brotherhood.None)
  );
  console.log(
    "Eye Accessories added: ",
    await descriptor.traitCount(TraitType.EyeAccessory, Brotherhood.None)
  );
  console.log(
    "Accessories added: ",
    await descriptor.traitCount(TraitType.Accessories, Brotherhood.None)
  );

  console.log(
    "Art mapping for Smol Joe 5",
    await seeder.getSpecialsArtMapping(5)
  );

  const gasPaid = balanceBefore.sub(await ethers.provider.getBalance(deployer));
  console.log(
    "Gas paid to populate the descriptor: ",
    ethers.utils.formatEther(gasPaid)
  );
});
