// SPDX-License-Identifier: GPL-3.0

/// @title Interface for SmolJoeSeeder

pragma solidity ^0.8.6;

import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeArt} from "./ISmolJoeArt.sol";

interface ISmolJoeSeeder {
    enum SmolJoeCast {
        Special,
        Unique,
        Common
    }

    struct Seed {
        ISmolJoeArt.Brotherhood brotherhood;
        uint16 specialId;
        uint16 uniqueId;
        uint16 background;
        uint16 body;
        uint16 pant;
        uint16 shoe;
        uint16 shirt;
        uint16 beard;
        uint16 head;
        uint16 eye;
        uint16 accessory;
    }

    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor, SmolJoeCast upgradeType)
        external
        returns (Seed memory);
}
