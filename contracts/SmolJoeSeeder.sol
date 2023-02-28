// SPDX-License-Identifier: GPL-3.0

/// @title The SmolJoes pseudo-random seed generator

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal} from "./interfaces/ISmolJoeDescriptorMinimal.sol";

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
        uint256 backgroundCount = descriptor.backgroundCount();
        uint256 bodyCount = descriptor.bodyCount();
        uint256 pantCount = descriptor.pantCount();
        uint256 shoeCount = descriptor.shoeCount();
        uint256 shirtCount = descriptor.shirtCount();
        uint256 beardCount = descriptor.beardCount();
        uint256 headCount = descriptor.headCount();
        uint256 eyeCount = descriptor.eyeCount();
        uint256 accessoryCount = descriptor.accessoryCount();

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
