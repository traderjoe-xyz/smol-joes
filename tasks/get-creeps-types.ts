import { task, types } from "hardhat/config";
import axios from "axios";

enum CreepType {
  Unknown,
  Bone,
  Zombie,
  Gold,
  Diamond,
  Unique,
}

interface Trait {
  trait_type: string;
  value: string;
}

const BATCH_REVEAL_OFFSET = 562;
const BASE_URL =
  "https://nftstorage.link/ipfs/bafybeib7okszfcmr57izgmtshc5lzmth5jggs5mhtykm7frlejfekdvabm/";

const creepTypesPrefetch = [
  5, 4, 1, 1, 1, 1, 1, 1, 3, 4, 1, 1, 3, 3, 1, 3, 1, 2, 1, 1, 1, 4, 1, 4, 2, 2,
  1, 1, 1, 5, 1, 1, 5, 1, 3, 1, 5, 1, 1, 5, 3, 5, 3, 1, 2, 5, 1, 1, 5, 2, 2, 3,
  5, 5, 4, 1, 1, 2, 1, 1, 1, 4, 1, 5, 1, 1, 1, 1, 3, 5, 3, 2, 5, 1, 2, 5, 2, 1,
  1, 1, 1, 1, 3, 4, 1, 1, 1, 1, 2, 2, 1, 1, 1, 3, 1, 2, 1, 1, 2, 5, 4, 5, 1, 1,
  5, 4, 1, 1, 1, 1, 1, 5, 4, 3, 2, 1, 3, 1, 4, 4, 5, 3, 3, 4, 5, 3, 5, 2, 4, 1,
  1, 3, 1, 1, 2, 1, 5, 5, 3, 1, 4, 3, 3, 1, 3, 1, 2, 1, 1, 2, 5, 3, 1, 1, 5, 1,
  1, 1, 1, 5, 1, 3, 3, 1, 1, 5, 1, 1, 4, 2, 1, 1, 1, 3, 1, 2, 3, 1, 3, 2, 1, 1,
  1, 3, 1, 5, 1, 3, 1, 5, 1, 3, 4, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 5,
  1, 1, 2, 1, 1, 1, 1, 1, 4, 2, 1, 1, 3, 3, 1, 3, 1, 1, 2, 1, 5, 1, 3, 3, 5, 3,
  1, 1, 5, 1, 1, 1, 1, 5, 3, 1, 1, 1, 2, 1, 1, 2, 4, 1, 3, 5, 1, 1, 1, 1, 1, 3,
  5, 1, 1, 3, 1, 1, 1, 5, 4, 1, 1, 3, 1, 1, 2, 1, 3, 1, 1, 2, 1, 1, 5, 1, 1, 1,
  1, 3, 4, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 5, 1, 2, 1, 5, 2, 1, 1, 1, 2, 1, 1, 1,
  2, 1, 3, 5, 1, 1, 1, 5, 5, 1, 1, 1, 1, 1, 1, 4, 2, 1, 4, 1, 1, 5, 2, 1, 2, 1,
  1, 4, 5, 2, 1, 1, 3, 1, 1, 5, 5, 1, 2, 5, 2, 1, 1, 1, 4, 5, 5, 4, 1, 4, 1, 1,
  1, 2, 2, 1, 3, 4, 1, 1, 3, 1, 1, 1, 3, 1, 3, 5, 5, 1, 4, 1, 3, 2, 1, 5, 1, 3,
  5, 5, 1, 5, 1, 1, 1, 1, 1, 5, 1, 1, 4, 1, 1, 1, 5, 2, 4, 1, 3, 3, 1, 1, 1, 5,
  3, 1, 5, 1, 1, 3, 1, 1, 1, 1, 3, 1, 2, 1, 3, 1, 5, 1, 1, 2, 3, 1, 2, 5, 1, 5,
  2, 1, 2, 5, 3, 1, 1, 5, 3, 2, 1, 2, 1, 4, 1, 1, 3, 1, 5, 1, 1, 3, 1, 3, 1, 1,
  1, 5, 4, 5, 1, 1, 4, 5, 1, 1, 1, 1, 3, 5, 5, 3, 4, 4, 1, 5, 1, 3, 5, 1, 1, 1,
  4, 1, 5, 1, 1, 3, 3, 1, 1, 1, 4, 1, 4, 2, 5, 1, 1, 1, 3, 1, 3, 2, 3, 1, 1, 3,
  1, 5, 1, 1, 1, 3, 4, 1, 1, 1, 1, 1, 1, 3, 1, 2, 3, 3, 1, 1, 3, 3, 3, 4, 1, 1,
  1, 3, 5, 1, 1, 2, 1, 3, 3, 3, 1, 1, 5, 4, 1, 1, 1, 1, 5, 5, 1, 1, 1, 5, 1, 5,
  1, 5, 1, 3, 1, 3, 3, 3, 5, 2, 1, 1, 1, 1, 2, 1, 3, 1, 1, 1, 2, 5, 1, 1, 2, 1,
  4, 1, 3, 3, 1, 1, 2, 1, 1, 1, 3, 1, 3, 1, 5, 1, 1, 5, 2, 1, 1, 2, 1, 2, 1, 1,
  1, 1, 2, 5, 1, 3, 1, 1, 4, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 3, 1, 1, 1, 3, 1, 1,
  1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 2, 4, 1, 1, 3, 1, 1, 5, 3, 1, 2, 3, 2, 1, 1,
  1, 1, 3, 2, 1, 2, 1, 1, 3, 1, 1, 3, 1, 3, 1, 1, 1, 1, 5, 1, 2, 1, 1, 5, 1, 1,
  5, 1, 1, 1, 1, 1, 1, 1, 3, 4, 3, 1, 4, 4, 2, 3, 1, 1, 5, 2, 4, 1, 3, 1, 1, 1,
  3, 4, 1, 1, 1, 1, 1, 1, 3, 1, 1, 2, 1, 1, 2, 4, 1, 3, 1, 2, 1, 5, 1, 1, 1, 5,
  1, 1, 1, 1, 1, 5, 1, 1, 1, 3, 1, 5, 1, 1, 1, 1, 1, 1, 4, 1, 3, 1, 1, 1, 1, 1,
  5, 1, 2, 1, 1, 1, 1, 3, 5, 1, 1, 2, 5, 3, 1, 1, 1, 1, 1, 1,
];

task(
  "get-creeps-types",
  "Fetches the metadata of the smol creeps collection to map their token id to their type (unique, diamond, gold, etc)"
)
  .addOptionalParam(
    "skip-ipfs-fetch",
    "Skips fetching the metadata on IPFS if it has already been done and the `creepTypesPrefetch` array is defined",
    false,
    types.boolean
  )
  .setAction(async () => {
    const creepTypes: CreepType[] = [];

    for (let i = 0; i < 800; i++) {
      const response = await axios.get(getImageURL(i));

      const attributes = response.data.attributes as Trait[];

      if (attributes.find((a) => a.trait_type === "Type").value === "Unique") {
        creepTypes.push(CreepType.Unique);
      } else if (
        attributes.find((a) => a.trait_type === "Body").value === "Diamond"
      ) {
        creepTypes.push(CreepType.Diamond);
      } else if (
        attributes.find((a) => a.trait_type === "Body").value === "Golden"
      ) {
        creepTypes.push(CreepType.Gold);
      } else if (
        attributes.find((a) => a.trait_type === "Body").value === "Zombie"
      ) {
        creepTypes.push(CreepType.Zombie);
      } else if (
        attributes.find((a) => a.trait_type === "Body").value ===
        "Nothing (Normal)"
      ) {
        creepTypes.push(CreepType.Bone);
      } else {
        creepTypes.push(CreepType.Unknown);
      }

      if (i > 0 && i % 10 === 0) {
        console.log(`Processed ${i} items`);
      }
    }

    console.log("\n====================================\n");

    console.dir(creepTypes, { maxArrayLength: null });

    console.log("\n====================================\n");

    console.log(
      `Unique found: ${creepTypes.filter((c) => c === CreepType.Unique).length}`
    );
    console.log(
      `Diamond found: ${
        creepTypes.filter((c) => c === CreepType.Diamond).length
      }`
    );
    console.log(
      `Gold found: ${creepTypes.filter((c) => c === CreepType.Gold).length}`
    );
    console.log(
      `Zombie found: ${creepTypes.filter((c) => c === CreepType.Zombie).length}`
    );
    console.log(
      `Bone found: ${creepTypes.filter((c) => c === CreepType.Bone).length}\n`
    );

    if (creepTypes.filter((c) => c === CreepType.Unknown).length > 0) {
      console.log("Unknown creep types found!");
    }

    console.log("\n====================================\n");

    // Converting the list into a byte string to be used in the contract
    let creepTypesBytes = "";
    let currentByte = 0;

    for (let i = 0; i < 64; i++) {
      const type = creepTypes[i];
      const bytePos = i % 2;

      currentByte += type.valueOf() << (bytePos * 4);

      if (bytePos === 1) {
        const byteString = `0${currentByte.toString(16)}`;
        creepTypesBytes += `\\x${byteString.slice(-2)}`;
        currentByte = 0;
      }
    }

    console.log(creepTypesBytes);
  });

const getImageURL = (id: number) => {
  return BASE_URL + ((id + BATCH_REVEAL_OFFSET) % 800);
};
