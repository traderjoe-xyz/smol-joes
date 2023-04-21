import { task } from "hardhat/config";
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

task(
  "get-creeps-types",
  "Fetches the metadata of the smol creeps collection to map their token id to their type (unique, diamond, gold, etc)"
).setAction(async () => {
  const creepTypes: CreepType[] = [];

  // Step 1: Get the old Smol Joe names in the order they were minted
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
    `Diamond found: ${creepTypes.filter((c) => c === CreepType.Diamond).length}`
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
});

const getImageURL = (id: number) => {
  return BASE_URL + ((id + BATCH_REVEAL_OFFSET) % 800);
};
