import { writeFileSync } from "fs";
import { task, types } from "hardhat/config";
import ImageData from "../files/image-data.json";
import { dataToDescriptorInput } from "./utils";
import path from "path";
import { ethers } from "ethers";

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

task(
  "make-descriptor-art",
  "Prints the descriptor art config in the final format, to be used in foundry / manual tests."
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
    const { bgcolors, palette, images } = ImageData;
    let { bodies, pants, shoes, shirts, beards, heads, eyes, accessories } =
      images;

    if (count !== undefined) {
      start = start === undefined ? 0 : start;

      bodies = bodies.slice(start, count + start);
      pants = pants.slice(start, count + start);
      shoes = shoes.slice(start, count + start);
      shirts = shirts.slice(start, count + start);
      beards = beards.slice(start, count + start);
      heads = heads.slice(start, count + start);
      eyes = eyes.slice(start, count + start);
      accessories = accessories.slice(start, count + start);
    }

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

    const paletteValue = `0x000000${palette.join("")}`;

    writeFileSync(
      path.join(exportPath, "paletteAndBackgrounds.abi"),
      ethers.utils.defaultAbiCoder.encode(
        ["bytes", "string[]"],
        [paletteValue, bgcolors]
      )
    );

    // console.log("=== PALETTE ===\n");
    // console.log(`paletteValue: '${paletteValue}'\n`);

    console.log("=== BODIES ===\n");
    // console.log(`bodiesCompressed: '${bodiesPage.encodedCompressed}'\n`);
    console.log(`bodiesLength: ${bodiesPage.originalLength}\n`);
    console.log(`bodies count: ${bodiesPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "bodiesPage.abi"), bodiesPage);

    console.log("=== PANTS ===\n");
    // console.log(`pantsCompressed: '${pantsPage.encodedCompressed}'\n`);
    console.log(`pantsLength: ${pantsPage.originalLength}\n`);
    console.log(`pants count: ${pantsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "pantsPage.abi"), pantsPage);

    console.log("=== SHOES ===\n");
    // console.log(`shoesCompressed: '${shoesPage.encodedCompressed}'\n`);
    console.log(`shoesLength: ${shoesPage.originalLength}\n`);
    console.log(`shoes count: ${shoesPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "shoesPage.abi"), shoesPage);

    console.log("=== SHIRTS ===\n");
    // console.log(`shirtsCompressed: '${shirtsPage.encodedCompressed}'\n`);
    console.log(`shirtsLength: ${shirtsPage.originalLength}\n`);
    console.log(`shirts count: ${shirtsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "shirtsPage.abi"), shirtsPage);

    console.log("=== BEARDS ===\n");
    // console.log(`beardsCompressed: '${beardsPage.encodedCompressed}'\n`);
    console.log(`beardsLength: ${beardsPage.originalLength}\n`);
    console.log(`beards count: ${beardsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "beardsPage.abi"), beardsPage);

    console.log("=== HEADS ===\n");
    // console.log(`headsCompressed: '${headsPage.encodedCompressed}'\n`);
    console.log(`headsLength: ${headsPage.originalLength}\n`);
    console.log(`heads count: ${headsPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "headsPage.abi"), headsPage);

    console.log("=== EYES ===\n");
    // console.log(`eyesCompressed: '${eyesPage.encodedCompressed}'\n`);
    console.log(`eyesLength: ${eyesPage.originalLength}\n`);
    console.log(`eyes count: ${eyesPage.itemCount}`);
    saveToFileAbiEncoded(path.join(exportPath, "eyesPage.abi"), eyesPage);

    console.log("=== ACCESSORIES ===\n");
    // console.log(`accessoriesCompressed: '${accessoriesPage.encodedCompressed}'\n`);
    console.log(`accessoriesLength: ${accessoriesPage.originalLength}\n`);
    console.log(`accessories count: ${accessoriesPage.itemCount}`);
    saveToFileAbiEncoded(
      path.join(exportPath, "accessoriesPage.abi"),
      accessoriesPage
    );
  });
