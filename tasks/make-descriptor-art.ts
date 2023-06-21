import { writeFileSync } from "fs";
import HundredsData1 from "../files/assets-data/hundreds-data-1.json";
import HundredsData2 from "../files/assets-data/hundreds-data-2.json";
import LuminariesData from "../files/assets-data/luminaries-data.json";
import { dataToDescriptorInput, Brotherhood } from "./utils";
import path from "path";
import { ethers } from "ethers";
import fs from "fs";

// Part 2 is smaller than part 1
const HUNDREDS_DATA_SLICE_1 = 18;
const HUNDREDS_DATA_SLICE_2 = 17;

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
};

const main = async () => {
  const cleanDirectory = true;
  const exportPath = path.join(__dirname, "../script/files/encoded-assets/");
  if (cleanDirectory) {
    const files = fs.readdirSync(exportPath);
    for (const file of files) {
      if (file === ".gitkeep") continue;

      fs.unlinkSync(path.join(exportPath, file));
    }
  }

  // ------------------ HUNDREDS ------------------
  console.log("\n========== HUNDREDS =========");
  const palette_1 = HundredsData1.palette;
  const images_1 = HundredsData1.images.hundreds;
  const dataLength_1 = [];

  for (let i = 0; i < 3; i++) {
    const bodypartsPage = dataToDescriptorInput(
      images_1
        .filter(
          (_, index) =>
            i * HUNDREDS_DATA_SLICE_1 <= index &&
            index < (i + 1) * HUNDREDS_DATA_SLICE_1
        )
        .map(({ data }) => data),
      images_1
        .filter(
          (_, index) =>
            i * HUNDREDS_DATA_SLICE_1 <= index &&
            index < (i + 1) * HUNDREDS_DATA_SLICE_1
        )
        .map(({ filename }) => filename)
    );

    saveToFileAbiEncoded(
      path.join(exportPath, `hundreds_page_${i}.abi`),
      bodypartsPage
    );

    dataLength_1.push(bodypartsPage.encodedCompressed.length / 2);
  }

  const paletteValue_1 = `0x000000${palette_1.join("")}`;

  writeFileSync(
    path.join(exportPath, "hundreds_palette_1.abi"),
    ethers.utils.defaultAbiCoder.encode(["bytes"], [paletteValue_1])
  );

  console.log("\n=== PALETTE ===");
  console.log(
    `palette for the Hundreds part 1: ${paletteValue_1.length / 2} bytes`
  );

  console.log("\n=== DATA LENGTH ===");
  console.log(`Data lengths for the Hundreds part 1: ${dataLength_1} bytes`);

  const palette_2 = HundredsData2.palette;
  const images_2 = HundredsData2.images.hundreds;
  const dataLength_2 = [];

  for (let i = 0; i < 3; i++) {
    const bodypartsPage = dataToDescriptorInput(
      images_2
        .filter(
          (_, index) =>
            i * HUNDREDS_DATA_SLICE_2 <= index &&
            index < (i + 1) * HUNDREDS_DATA_SLICE_2
        )
        .map(({ data }) => data),
      images_2
        .filter(
          (_, index) =>
            i * HUNDREDS_DATA_SLICE_2 <= index &&
            index < (i + 1) * HUNDREDS_DATA_SLICE_2
        )
        .map(({ filename }) => filename)
    );

    saveToFileAbiEncoded(
      path.join(exportPath, `hundreds_page_${i + 3}.abi`),
      bodypartsPage
    );

    dataLength_2.push(bodypartsPage.encodedCompressed.length / 2);
  }

  const paletteValue_2 = `0x000000${palette_2.join("")}`;

  writeFileSync(
    path.join(exportPath, "hundreds_palette_2.abi"),
    ethers.utils.defaultAbiCoder.encode(["bytes"], [paletteValue_2])
  );

  console.log("\n=== PALETTE ===");
  console.log(
    `palette for the Hundreds part 2: ${paletteValue_2.length / 2} bytes`
  );

  console.log("\n=== DATA LENGTH ===");
  console.log(`Data lengths for the Hundreds part 2: ${dataLength_2} bytes`);

  // ------------------ LUMINARIES ------------------
  console.log("\n========== LUMINARIES =========");

  let luminariesPagesAmount = 0;
  const { palette, images, emblems, metadatas } = LuminariesData;

  let {
    luminaries,
    backgrounds,
    bodies,
    shoes,
    pants,
    shirts,
    beards,
    hairs_caps_heads,
    eye_accessories,
    accessories,
  } = images;

  // Create a list of all bodyparts
  const bodyparts = [
    { object: luminaries, name: "luminaries" },
    { object: backgrounds, name: "backgrounds" },
    { object: bodies, name: "bodies" },
    { object: shoes, name: "shoes" },
    { object: pants, name: "pants" },
    { object: shirts, name: "shirts" },
    { object: beards, name: "beards" },
    { object: hairs_caps_heads, name: "heads" },
    { object: eye_accessories, name: "eyes" },
    { object: accessories, name: "accessories" },
  ];

  Object.keys(Brotherhood).map((brotherhood) => {
    if (!isNaN(Number(brotherhood))) return;

    bodyparts.forEach((bodypart) => {
      const brotherhoodBodyparts = bodypart.object.filter(
        (item) => item.brotherhood === brotherhood
      );

      if (brotherhoodBodyparts.length > 0) {
        const bodypartsPage = dataToDescriptorInput(
          brotherhoodBodyparts.map(({ data }) => data),
          brotherhoodBodyparts.map(({ filename }) => filename)
        );

        saveToFileAbiEncoded(
          path.join(exportPath, `${bodypart.name}_${brotherhood}_page.abi`),
          bodypartsPage
        );

        luminariesPagesAmount++;
      }
    });
  });

  const paletteValue = `0x000000${palette.join("")}`;

  writeFileSync(
    path.join(exportPath, "luminaries_palette.abi"),
    ethers.utils.defaultAbiCoder.encode(["bytes"], [paletteValue])
  );

  emblems.forEach((emblem) => {
    writeFileSync(
      path.join(exportPath, `emblem_${emblem.brotherhood}.abi`),
      emblem.data
    );
  });

  Object.keys(Brotherhood).forEach((brotherhood) => {
    if (!isNaN(Number(brotherhood))) return;

    const metadata = metadatas.filter(
      (metadata) => metadata.brotherhood === brotherhood
    );

    console.log(brotherhood);

    writeFileSync(
      path.join(exportPath, `metadata_${brotherhood}.abi`),
      ethers.utils.defaultAbiCoder.encode(
        ["string[]"],
        [metadata.map(({ data }) => data)]
      )
    );
  });

  console.log("\n=== PALETTE ===");
  console.log(`palette luminaries: ${palette.length}`);

  console.log("\n=== BODY PARTS ===");
  console.log(`${luminariesPagesAmount} pages`);

  console.log("\n=== EMBLEMS ===");
  console.log(`emblems length: ${emblems.length}`);

  console.log("\n=== METADATA ===");
  console.log(`metadatas ok`);
};

main();
