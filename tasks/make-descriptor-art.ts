import { writeFileSync } from "fs";
import { task, types } from "hardhat/config";
import ImageData from "../files/image-data.json";
import { dataToDescriptorInput } from "./utils";
import path from "path";
import { ethers } from "ethers";

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

task(
  "make-descriptor-art",
  "Writes the descriptor art config in the final format, to be used in foundry / manual tests."
)
  .addOptionalParam(
    "exportPath",
    "Where to save abi encoded files to be used in forge tests",
    path.join(__dirname, "../test/files/encoded-assets/")
  )
  .setAction(async ({ exportPath }, { ethers }) => {
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
      uniques,
      specials,
    } = images;

    // Create a list of all bodyparts
    const bodyparts = [
      { object: background, name: "backgrounds" },
      { object: body, name: "bodies" },
      { object: shoes, name: "shoes" },
      { object: pants, name: "pants" },
      { object: shirt, name: "shirts" },
      { object: beard, name: "beards" },
      { object: hair_cap_head, name: "heads" },
      { object: eye_accessory, name: "eyes" },
      { object: accessories, name: "accessories" },
      { object: uniques, name: "uniques" },
      { object: specials, name: "specials" },
    ];

    Object.keys(Brotherhood).map((brotherhood) => {
      bodyparts.forEach((bodypart) => {
        const brotherhoodBodyparts = bodypart.object.filter(
          (item) =>
            item.brotherhood ===
            (brotherhood === "MagicalBeings" ? "Magical Beings" : brotherhood)
        );

        if (brotherhoodBodyparts.length > 0) {
          if (bodypart.name === "specials") {
            const bodypartsPage = dataToDescriptorInput(
              brotherhoodBodyparts
                .filter((_, index) => index < 50)
                .map(({ data }) => data),
              brotherhoodBodyparts
                .filter((_, index) => index < 50)
                .map(({ filename }) => filename)
            );

            saveToFileAbiEncoded(
              path.join(exportPath, `${bodypart.name}${brotherhood}Page.abi`),
              bodypartsPage
            );

            const bodypartsPage_2 = dataToDescriptorInput(
              brotherhoodBodyparts
                .filter((_, index) => index >= 50)
                .map(({ data }) => data),
              brotherhoodBodyparts
                .filter((_, index) => index >= 50)
                .map(({ filename }) => filename)
            );

            saveToFileAbiEncoded(
              path.join(exportPath, `${bodypart.name}${brotherhood}Page_2.abi`),
              bodypartsPage_2
            );
          } else {
            const bodypartsPage = dataToDescriptorInput(
              brotherhoodBodyparts.map(({ data }) => data),
              brotherhoodBodyparts.map(({ filename }) => filename)
            );

            saveToFileAbiEncoded(
              path.join(exportPath, `${bodypart.name}${brotherhood}Page.abi`),
              bodypartsPage
            );
          }
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
