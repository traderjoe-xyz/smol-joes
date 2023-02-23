// SPDX-License-Identifier: GPL-3.0

/// @title Interface for SmolJoeSeeder

pragma solidity ^0.8.6;

import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";

interface ISmolJoeSeeder {
    enum SmolJoeCast {
        Special,
        Unique,
        Common
    }

    struct Seed {
        uint48 background;
        uint48 body;
        uint48 pant;
        uint48 shoe;
        uint48 shirt;
        uint48 beard;
        uint48 head;
        uint48 eye;
        uint48 accessory;
    }

    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor) external view returns (Seed memory);
}
