import { writeFileSync, readFileSync } from "fs";
import path from "path";
import { convert } from "convert-svg-to-png";

const main = async () => {
  const tokenId = process.argv[2];
  const fileName = process.argv[3];

  const uriPath = "../script/files/raw-uris-sample/";
  const metadataPath = "../script/files/metadatas-sample/";
  const imagePath = "../script/files/images-sample/";

  const tokenURI = readFileSync(
    path.join(__dirname, uriPath, tokenId.toString() + ".txt")
  ).toString();

  const decodedTokenURI = Buffer.from(
    tokenURI.replace("data:application/json;base64,", ""),
    "base64"
  ).toString("utf-8");

  console.log(decodedTokenURI);

  const tokenMetadata = JSON.parse(decodedTokenURI);

  const svg = Buffer.from(
    tokenMetadata.image.replace("data:image/svg+xml;base64,", ""),
    "base64"
  ).toString("utf-8");

  tokenMetadata.image = "...";

  writeFileSync(
    path.join(
      __dirname,
      metadataPath,
      (fileName ?? tokenId.toString()) + ".json"
    ),
    JSON.stringify(tokenMetadata, undefined, 4)
  );

  writeFileSync(
    path.join(__dirname, imagePath, (fileName ?? tokenId.toString()) + ".png"),
    await convert(svg)
  );
};

main();
