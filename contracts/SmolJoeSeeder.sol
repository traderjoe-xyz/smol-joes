// SPDX-License-Identifier: GPL-3.0

/// @title The SmolJoes pseudo-random seed generator

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal, ISmolJoeArt} from "./interfaces/ISmolJoeDescriptorMinimal.sol";

contract SmolJoeSeeder is ISmolJoeSeeder {
    uint256[7] public uniquesArt;

    uint256 private constant MASK_UINT16 = 0xffff;

    function updateUniquesArtMapping(uint16[100] calldata artMapping) external {
        uint256 packedMapping;
        for (uint256 i = 0; i < artMapping.length; i++) {
            packedMapping += uint256(artMapping[i]) << (i % 16) * 16;

            if ((i + 1) % 16 == 0) {
                uniquesArt[i / 16] = packedMapping;
                packedMapping = 0;
            }
        }

        uniquesArt[6] = packedMapping;
    }

    function getUniqueArtMapping(uint256 tokenId) external view returns (uint16) {
        return _getUniqueArtMapping(tokenId);
    }

    function _getUniqueArtMapping(uint256 tokenId) internal view returns (uint16) {
        return uint16((uniquesArt[tokenId / 16] >> (tokenId % 16) * 16) & MASK_UINT16);
    }
    /**
     * @notice Generate a pseudo-random Smol Joe seed using the previous blockhash and noun ID.
     */

    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor, SmolJoeCast upgradeType)
        external
        view
        override
        returns (Seed memory)
    {
        uint256 pseudoRandomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), tokenId)));

        uint256 backgroundCount = descriptor.traitCount(ISmolJoeArt.TraitType.Background);
        uint256 bodyCount = descriptor.traitCount(ISmolJoeArt.TraitType.Body);
        uint256 pantCount = descriptor.traitCount(ISmolJoeArt.TraitType.Pants);
        uint256 shoeCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shoes);
        uint256 shirtCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shirt);
        uint256 beardCount = descriptor.traitCount(ISmolJoeArt.TraitType.Beard);
        uint256 headCount = descriptor.traitCount(ISmolJoeArt.TraitType.HairCapHead);
        uint256 eyeCount = descriptor.traitCount(ISmolJoeArt.TraitType.EyeAccessory);
        uint256 accessoryCount = descriptor.traitCount(ISmolJoeArt.TraitType.Accessories);

        uint16 specialSeed = upgradeType == SmolJoeCast.Special ? _getUniqueArtMapping(tokenId) : 0;

        return Seed({
            smolJoeType: upgradeType,
            special: specialSeed,
            background: uint16(uint16(pseudoRandomness) % backgroundCount),
            body: uint16(uint16(pseudoRandomness >> 16) % (bodyCount - 1) + 1),
            pant: uint16(uint16(pseudoRandomness >> 32) % pantCount),
            shoe: uint16(uint16(pseudoRandomness >> 48) % shoeCount),
            shirt: uint16(uint16(pseudoRandomness >> 64) % shirtCount),
            beard: uint16(uint16(pseudoRandomness >> 80) % beardCount),
            head: uint16(uint16(pseudoRandomness >> 96) % headCount),
            eye: uint16(uint16(pseudoRandomness >> 112) % eyeCount),
            accessory: uint16(uint16(pseudoRandomness >> 128) % accessoryCount)
        });
    }
}
