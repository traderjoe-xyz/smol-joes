// SPDX-License-Identifier: GPL-3.0

/// @title The SmolJoes pseudo-random seed generator

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal} from "./interfaces/ISmolJoeDescriptorMinimal.sol";

contract SmolJoeSeeder is ISmolJoeSeeder {
    /**
     * @notice Generate a pseudo-random Smol Joe seed using the previous blockhash and noun ID.
     */
    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor)
        external
        view
        override
        returns (Seed memory)
    {
        uint256 pseudorandomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), tokenId)));

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
            background: uint48(uint48(pseudorandomness) % backgroundCount),
            body: uint48(uint48(pseudorandomness >> 48) % bodyCount),
            pant: uint48(uint48(pseudorandomness >> 96) % pantCount),
            shoe: uint48(uint48(pseudorandomness >> 144) % shoeCount),
            shirt: uint48(uint48(pseudorandomness >> 192) % shirtCount),
            beard: uint48(uint48(pseudorandomness >> 240) % beardCount),
            head: uint48(uint48(pseudorandomness >> 288) % headCount),
            eye: uint48(uint48(pseudorandomness >> 336) % eyeCount),
            accessory: uint48(uint48(pseudorandomness >> 384) % accessoryCount)
        });
    }
}
