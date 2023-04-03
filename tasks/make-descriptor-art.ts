import { writeFileSync } from "fs";
import { task, types } from "hardhat/config";
import ImageData from "../files/image-data.json";
import { dataToDescriptorInput } from "./utils";
import path from "path";
import { ethers } from "ethers";

task(
  "make-descriptor-art",
  "Writes the descriptor art config in the final format, to be used in foundry / manual tests."
)
  .addOptionalParam(
    "count",
    "The length of the image slice to take from each of the image arrays",
    undefined,
    types.int
  )
  .addOptionalParam(
    "start",
    "The index at which to start the image slice",
    undefined,
    types.int
  )
  .addOptionalParam(
    "exportPath",
    "Where to save abi encoded files to be used in forge tests",
    path.join(__dirname, "../test/files/encoded-assets/")
  )
  .setAction(async ({ count, start, exportPath }, { ethers }) => {
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
      specials,
    } = images;

    if (count !== undefined) {
      start = start === undefined ? 0 : start;

      background = background.slice(start, count + start);
      body = body.slice(start, count + start);
      pants = pants.slice(start, count + start);
      shoes = shoes.slice(start, count + start);
      shirt = shirt.slice(start, count + start);
      beard = beard.slice(start, count + start);
      hair_cap_head = hair_cap_head.slice(start, count + start);
      eye_accessory = eye_accessory.slice(start, count + start);
      accessories = accessories.slice(start, count + start);
      specials = specials.slice(start, count + start);
    }

    console.log("dataToDescriptorInput start");

    const backgroundsPage = dataToDescriptorInput(
      background.map(({ data }) => data),
      background.map(({ filename }) => filename)
    );

    console.log("backgroundsPage done");

    const bodiesPage = dataToDescriptorInput(
      body.map(({ data }) => data),
      body.map(({ filename }) => filename)
    );

    console.log("bodiesPage done");

    const shoesPage = dataToDescriptorInput(
      shoes.map(({ data }) => data),
      shoes.map(({ filename }) => filename)
    );

    console.log("shoesPage done");

    const pantsPage = dataToDescriptorInput(
      pants.map(({ data }) => data),
      pants.map(({ filename }) => filename)
    );

    console.log("pantsPage done");

    const shirtsPage = dataToDescriptorInput(
      shirt.map(({ data }) => data),
      shirt.map(({ filename }) => filename)
    );

    console.log("shirtsPage done");

    const beardsPage = dataToDescriptorInput(
      beard.map(({ data }) => data),
      beard.map(({ filename }) => filename)
    );

    console.log("beardsPage done");

    const headsPage = dataToDescriptorInput(
      hair_cap_head.map(({ data }) => data),
      hair_cap_head.map(({ filename }) => filename)
    );

    console.log("headsPage done");

    const eyesPage = dataToDescriptorInput(
      eye_accessory.map(({ data }) => data),
      eye_accessory.map(({ filename }) => filename)
    );

    console.log("eyesPage done");

    const accessoriesPage = dataToDescriptorInput(
      accessories.map(({ data }) => data),
      accessories.map(({ filename }) => filename)
    );

    console.log("accessoriesPage done");

    const specialsPage = dataToDescriptorInput(
      specials.map(({ data }) => data),
      specials.map(({ filename }) => filename)
    );

    console.log("specialsPage done");

    const paletteValue = `0x000000${palette.join("")}`;

    writeFileSync(
      path.join(exportPath, "palette.abi"),
      ethers.utils.defaultAbiCoder.encode(["bytes"], [paletteValue])
    );

    console.log("=== PALETTE ===\n");
    console.log(`palette length: '${palette.length}'\n`);

    console.log("=== BACKGROUNDS ===\n");
    console.log(`backgroundsLength: ${backgroundsPage.originalLength}\n`);
    console.log(`backgrounds count: ${backgroundsPage.itemCount}`);
    saveToFileAbiEncoded(
      path.join(exportPath, "backgroundsPage.abi"),
      backgroundsPage
    );

    console.log("=== BODIES ===\n");
    console.log(`bodiesLength: ${bodiesPage.originalLength}\n`);
    console.log(`bodies count: ${bodiesPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "bodiesPage.abi"), bodiesPage);

    console.log("=== SHOES ===\n");
    console.log(`shoesLength: ${shoesPage.originalLength}\n`);
    console.log(`shoes count: ${shoesPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "shoesPage.abi"), shoesPage);

    console.log("=== PANTS ===\n");
    console.log(`pantsLength: ${pantsPage.originalLength}\n`);
    console.log(`pants count: ${pantsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "pantsPage.abi"), pantsPage);

    console.log("=== SHIRTS ===\n");
    console.log(`shirtsLength: ${shirtsPage.originalLength}\n`);
    console.log(`shirts count: ${shirtsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "shirtsPage.abi"), shirtsPage);

    console.log("=== BEARDS ===\n");
    console.log(`beardsLength: ${beardsPage.originalLength}\n`);
    console.log(`beards count: ${beardsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "beardsPage.abi"), beardsPage);

    console.log("=== HAIRS-CAPS-HEADS ===\n");
    console.log(`headsLength: ${headsPage.originalLength}\n`);
    console.log(`heads count: ${headsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "headsPage.abi"), headsPage);

    console.log("=== EYES ACCESSORIES ===\n");
    console.log(`eyesLength: ${eyesPage.originalLength}\n`);
    console.log(`eyes count: ${eyesPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "eyesPage.abi"), eyesPage);

    console.log("=== ACCESSORIES ===\n");
    console.log(`accessoriesLength: ${accessoriesPage.originalLength}\n`);
    console.log(`accessories count: ${accessoriesPage.itemCount}`);
    saveToFileAbiEncoded(
      path.join(exportPath, "accessoriesPage.abi"),
      accessoriesPage
    );

    console.log("=== SPECIALS ===\n");
    console.log(`specialsLength: ${specialsPage.originalLength}\n`);
    console.log(`specials count: ${specialsPage.itemCount}`);
    saveToFileAbiEncoded(
      path.join(exportPath, "specialsPage.abi"),
      specialsPage
    );
  });

const saveToFileAbiEncoded = (
  filepath: string,
  traitPage: {
    encodedCompressed: string;
    originalLength: number;
    itemCount: number;
  }
) => {
  const abiEncoded = ethers.utils.defaultAbiCoder.encode(
    ["bytes", "uint80", "uint16"],
    [traitPage.encodedCompressed, traitPage.originalLength, traitPage.itemCount]
  );
  writeFileSync(filepath, abiEncoded);
  console.log(`Saved traitPage to ${filepath}`);
};
