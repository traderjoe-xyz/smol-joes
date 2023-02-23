// SPDX-License-Identifier: GPL-3.0

/// @title The SmolJoes pseudo-random seed generator

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal} from "./interfaces/ISmolJoeDescriptorMinimal.sol";

contract SmolJoeSeeder is ISmolJoeSeeder {
    /**
     * @notice Generate a pseudo-random Smol Joe seed using the previous blockhash and noun ID.
     */
    function generateSeed(uint256 smolJoeId, ISmolJoeDescriptorMinimal descriptor)
        external
        view
        override
        returns (Seed memory)
    {
        uint256 pseudorandomness = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), smolJoeId)));

        uint256 backgroundCount = descriptor.backgroundCount();
        uint256 bodyCount = descriptor.bodyCount();
        uint256 headCount = descriptor.headCount();

        return Seed({
            background: uint48(uint48(pseudorandomness) % backgroundCount),
            body: uint48(uint48(pseudorandomness >> 48) % bodyCount),
            head: uint48(uint48(pseudorandomness >> 96) % headCount)
        });
    }
}
