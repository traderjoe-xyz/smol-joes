// SPDX-License-Identifier: GPL-3.0

/// @title The SmolJoes pseudo-random seed generator

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal, ISmolJoeArt} from "./interfaces/ISmolJoeDescriptorMinimal.sol";

contract SmolJoeSeeder is ISmolJoeSeeder {
    /**
     * @notice Generate a pseudo-random Smol Joe seed using the previous blockhash and noun ID.
     */
    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor, SmolJoeCast upgradeType)
        external
        view
        override
        returns (Seed memory)
    {
        upgradeType;

        uint256 pseudoRandomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), tokenId)));
        uint256 backgroundCount = descriptor.traitCount(ISmolJoeArt.TraitType.Backgrounds);
        uint256 bodyCount = descriptor.traitCount(ISmolJoeArt.TraitType.Bodies);
        uint256 pantCount = descriptor.traitCount(ISmolJoeArt.TraitType.Pants);
        uint256 shoeCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shoes);
        uint256 shirtCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shirts);
        uint256 beardCount = descriptor.traitCount(ISmolJoeArt.TraitType.Beards);
        uint256 headCount = descriptor.traitCount(ISmolJoeArt.TraitType.Heads);
        uint256 eyeCount = descriptor.traitCount(ISmolJoeArt.TraitType.Eyes);
        uint256 accessoryCount = descriptor.traitCount(ISmolJoeArt.TraitType.Accessories);

        return Seed({
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
