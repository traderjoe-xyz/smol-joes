import { writeFileSync } from "fs";
import { task } from "hardhat/config";
import ImageData from "../files/assets-data/image-data.json";
import { dataToDescriptorInput, Brotherhood } from "./utils";
import path from "path";
import { ethers } from "ethers";
import fs from "fs";

task(
  "make-descriptor-art",
  "Writes the descriptor art config in the final format, to be used in foundry / manual tests."
)
  .addParam(
    "cleanDirectory",
    "Delete all files in exportPath before saving new files"
  )
  .addOptionalParam(
    "exportPath",
    "Where to save abi encoded files to be used in forge tests",
    path.join(__dirname, "../script/files/encoded-assets/")
  )

  .setAction(async ({ exportPath, cleanDirectory }, { ethers }) => {
    if (cleanDirectory) {
      const files = fs.readdirSync(exportPath);
      for (const file of files) {
        if (file === ".gitkeep") continue;

        fs.unlinkSync(path.join(exportPath, file));
      }
    }

    const { palette, images } = ImageData;

    let {
      hundreds,
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
      houses,
    } = images;

    // Create a list of all bodyparts
    const bodyparts = [
      { object: hundreds, name: "hundreds" },
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
      { object: houses, name: "houses" },
    ];

    Object.keys(Brotherhood).map((brotherhood) => {
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
        }
      });
    });

    const paletteValue = `0x000000${palette.join("")}`;

    writeFileSync(
      path.join(exportPath, "palette.abi"),
      ethers.utils.defaultAbiCoder.encode(["bytes"], [paletteValue])
    );

    console.log("\n=== PALETTE ===");
    console.log(`palette length: ${palette.length}`);
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
