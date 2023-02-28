import { writeFileSync, readFileSync } from "fs";
import { task, types } from "hardhat/config";
import ImageData from "../files/image-data.json";
import { dataToDescriptorInput } from "./utils";
import path from "path";
import { ethers } from "ethers";
import { convert } from "convert-svg-to-png";

task(
  "render-images",
  "Generate PNG images from the SVGs provided by the descriptor"
)
  .addParam("tokenId", "ID of the token to be generated", undefined, types.int)
  .addOptionalParam(
    "uriPath",
    "Location of the raw URI to render",
    "../test/files/raw-uris-sample/",
    types.string
  )
  .addOptionalParam(
    "imagePath",
    "Location of generated PNGs",
    "../test/files/images-sample/",
    types.string
  )
  .setAction(async ({ tokenId, uriPath, imagePath }, {}) => {
    const tokenURI = readFileSync(
      path.join(__dirname, uriPath, tokenId.toString() + ".txt")
    ).toString();
    const decodedTokenURI = Buffer.from(
      tokenURI.replace("data:application/json;base64,", ""),
      "base64"
    ).toString("utf-8");
    const svg = Buffer.from(
      JSON.parse(decodedTokenURI).image.replace(
        "data:image/svg+xml;base64,",
        ""
      ),
      "base64"
    ).toString("utf-8");
    writeFileSync(
      path.join(__dirname, imagePath, tokenId.toString() + ".png"),
      await convert(svg)
    );
  });
