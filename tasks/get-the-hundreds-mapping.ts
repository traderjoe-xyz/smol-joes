import { task } from "hardhat/config";
import axios from "axios";

import HundredsData1 from "../files/assets-data/hundreds-data-1.json";
import HundredsData2 from "../files/assets-data/hundreds-data-2.json";

const BATCH_REVEAL_OFFSET = 75;
const BASE_URL =
  "https://nftstorage.link/ipfs/bafybeihosc6jrek4ow4jolwgrimig4phfth7d5hgjy4xfpdba4wdy3troy/";

// Mapping of the Smol Joes that changed their name
// old => new
const MAP: Map<string, string> = new Map();

// New art
MAP.set("Smol Doodles Joe", "Smol Astronaut Joe");
MAP.set("Smol Azuki Joe", "Smol Biker Joe");
MAP.set("Smol Bean Joe", "Smol Peon Joe");
MAP.set("Smol Okay Bears Joe", "Smol Ken Joe");
MAP.set("Smol Cool Cats Joe", "Smol Party Joe");
MAP.set("Smol Moonbirds Joe", "Smol Builder Joe");
MAP.set("Smol Yeti Joe", "Smol Magic Mike Joe");
MAP.set("Smol Cryptofish Joe", "Smol Robin Hood Joe");
MAP.set("Smol Murloc Joe", "Smol Stoner Joe");
MAP.set("Smol Ukuzu Joe", "Smol Sailor Joe");
MAP.set("Smol Pixelmon Joe", "Smol King Joe");
MAP.set("Smol Bridge Joe", "Smol Sherpa Joe");
MAP.set("Smol Flubber Joe", "Smol Doctor Joe");
MAP.set("Smol Green Glow Joe", "Smol GI Joe");
MAP.set("Smol rJoe", "Smol LB Joe");

// Major Name change
MAP.set("Smol Darth Joe", "Smol Dark Lord Joe");
MAP.set("Smol Matrix Joe", "Smol Red Pill Joe");
MAP.set("Smol Saylor Joe", "Smol BTC Maxi Joe");
MAP.set("Smol Blue Joe", "Smol Blue Cat Joe");

// Minor Name change
MAP.set("Smol Hotdog Joe", "Smol Hot Dog Joe");
MAP.set("Smol Volly", "Smol Volley Joe");
MAP.set("Smol xJoe", "Smol xJOE Joe");
MAP.set("Smol sJoe", "Smol sJOE Joe");
MAP.set("Smol veJoe", "Smol veJOE Joe");
MAP.set("Smol Radioactive Suit Joe", "Smol Hazmat Joe");

task(
  "get-the-hundreds-mapping",
  "Fetches the metadata of the original Smol Joes collection to match the old NFT IDs to the new ones"
).setAction(async () => {
  const oldSmolJoes = [];
  const newSmolJoes = [];
  const mapping = [];

  // Step 1: Get the old Smol Joe names in the order they were minted
  for (let i = 0; i < 100; i++) {
    const response = await axios.get(getImageURL(i));
    oldSmolJoes.push(response.data.name);
  }

  // Step 2: Get the new Smol Joe list in the order it has been uploaded to the Art contract
  newSmolJoes.push(...HundredsData1.images.hundreds.map((h) => h.filename));
  newSmolJoes.push(...HundredsData2.images.hundreds.map((h) => h.filename));

  // Step 3: Match the old Smol Joe names to the new ones
  for (let i = 0; i < 100; i++) {
    const oldName = oldSmolJoes[i];
    const newName = MAP.get(oldName) || oldName;
    const newIndex = newSmolJoes.indexOf(newName);

    if (newIndex === -1) {
      console.log(`Could not find ${oldName} in the new Smol Joes list`);
      continue;
    }

    mapping.push(newIndex);
  }

  console.log(`Mapping: ${mapping.length} items`);
  console.log(mapping);
});

const getImageURL = (id: number) => {
  return BASE_URL + ((id + BATCH_REVEAL_OFFSET) % 100);
};
