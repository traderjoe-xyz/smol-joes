// SPDX-License-Identifier: GPL-3.0

/// @title The SmolJoes pseudo-random seed generator

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal, ISmolJoeArt} from "./interfaces/ISmolJoeDescriptorMinimal.sol";

contract SmolJoeSeeder is ISmolJoeSeeder {
    uint256[7] public specialsArt;
    uint256[] public uniquesAvailable = [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
        33,
        34,
        35,
        36,
        37,
        38,
        39,
        40,
        41,
        42,
        43,
        44,
        45,
        46,
        47,
        48,
        49,
        50,
        51,
        52,
        53,
        54,
        55,
        56,
        57,
        58,
        59,
        60,
        61,
        62,
        63,
        64,
        65,
        66,
        67,
        68,
        69,
        70,
        71,
        72,
        73,
        74,
        75,
        76,
        77,
        78,
        79,
        80,
        81,
        82,
        83,
        84,
        85,
        86,
        87,
        88,
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        98,
        99
    ];

    uint256 private constant MASK_UINT16 = 0xffff;

    function updateUniquesArtMapping(uint16[100] calldata artMapping) external {
        uint256 packedMapping;
        for (uint256 i = 0; i < artMapping.length; i++) {
            packedMapping += uint256(artMapping[i]) << (i % 16) * 16;

            if ((i + 1) % 16 == 0) {
                specialsArt[i / 16] = packedMapping;
                packedMapping = 0;
            }
        }

        specialsArt[6] = packedMapping;
    }

    function getUniqueArtMapping(uint256 tokenId) external view returns (uint16) {
        return _getUniqueArtMapping(tokenId);
    }

    function _getUniqueArtMapping(uint256 tokenId) internal view returns (uint16) {
        return uint16((specialsArt[tokenId / 16] >> (tokenId % 16) * 16) & MASK_UINT16);
    }
    /**
     * @notice Generate a pseudo-random Smol Joe seed using the previous blockhash and noun ID.
     */

    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor, SmolJoeCast upgradeType)
        external
        override
        returns (Seed memory)
    {
        uint256 pseudoRandomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), tokenId)));

        // Need to store the seed into memory to prevent stack too deep errors
        Seed memory seed;

        if (tokenId < 100) {
            seed.specialId = _getUniqueArtMapping(tokenId) + 1;
        } else if (tokenId < 200) {
            uint256 uniquesAvailableLength = uniquesAvailable.length;

            uint256 randomIndex = pseudoRandomness % uniquesAvailableLength;
            uint256 randomUnique = uniquesAvailable[randomIndex];

            seed.uniqueId = uint16(randomUnique % 10) + 1;
            // Pick the corresponding brotherhood (1-10)
            seed.brotherhood = ISmolJoeArt.Brotherhood(randomUnique / 10 + 1);

            // Remove the unique from the available list
            uniquesAvailable[randomIndex] = uniquesAvailable[uniquesAvailableLength - 1];
            uniquesAvailable.pop();
        } else {
            ISmolJoeArt.Brotherhood brotherhood = ISmolJoeArt.Brotherhood(uint8(pseudoRandomness % 10));
            seed.brotherhood = brotherhood;

            uint256 backgroundCount =
                descriptor.traitCount(ISmolJoeArt.TraitType.Background, ISmolJoeArt.Brotherhood.None);
            seed.background = uint16(uint16(pseudoRandomness) % backgroundCount);

            uint256 bodyCount = descriptor.traitCount(ISmolJoeArt.TraitType.Body, ISmolJoeArt.Brotherhood.None);
            seed.body = uint16(uint16(pseudoRandomness >> 16) % (bodyCount - 1) + 1);

            uint256 pantCount = descriptor.traitCount(ISmolJoeArt.TraitType.Pants, ISmolJoeArt.Brotherhood.None);

            seed.pant = uint16(uint16(pseudoRandomness >> 32) % pantCount);

            uint256 shoeCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shoes, ISmolJoeArt.Brotherhood.None);
            seed.shoe = uint16(uint16(pseudoRandomness >> 48) % shoeCount);

            uint256 shirtCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shirt, ISmolJoeArt.Brotherhood.None);
            seed.shirt = uint16(uint16(pseudoRandomness >> 64) % shirtCount);

            uint256 beardCount = descriptor.traitCount(ISmolJoeArt.TraitType.Beard, ISmolJoeArt.Brotherhood.None);
            seed.beard = uint16(uint16(pseudoRandomness >> 80) % beardCount);

            uint256 headCount = descriptor.traitCount(ISmolJoeArt.TraitType.HairCapHead, ISmolJoeArt.Brotherhood.None);
            seed.head = uint16(uint16(pseudoRandomness >> 96) % headCount);

            uint256 eyeCount = descriptor.traitCount(ISmolJoeArt.TraitType.EyeAccessory, ISmolJoeArt.Brotherhood.None);
            seed.eye = uint16(uint16(pseudoRandomness >> 112) % eyeCount);

            uint256 accessoryCount =
                descriptor.traitCount(ISmolJoeArt.TraitType.Accessories, ISmolJoeArt.Brotherhood.None);
            seed.accessory = uint16(uint16(pseudoRandomness >> 128) % accessoryCount);
        }

        return seed;
    }
}
