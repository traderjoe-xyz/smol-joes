import { ethers } from "ethers";
import { deflateRawSync } from "zlib";
import { Brotherhood } from "./types";

export { Brotherhood };

export function dataToDescriptorInput(
  data: string[],
  traitNames: string[]
): {
  encodedCompressed: string;
  originalLength: number;
  itemCount: number;
} {
  const abiEncoded = ethers.utils.defaultAbiCoder.encode(
    ["bytes[]", "string[]"],
    [data, traitNames]
  );

  const encodedCompressed = `0x${deflateRawSync(
    Buffer.from(abiEncoded.substring(2), "hex")
  ).toString("hex")}`;

  const originalLength = abiEncoded.substring(2).length / 2;
  const itemCount = data.length;

  return {
    encodedCompressed,
    originalLength,
    itemCount,
  };
}

/**
 * Split an array into smaller chunks
 * @param array The array
 * @param size The chunk size
 */
export const chunkArray = <T>(array: T[], size: number): T[][] => {
  const chunk: T[][] = [];
  for (let i = 0; i < array.length; i += size) {
    chunk.push(array.slice(i, i + size));
  }
  return chunk;
};
