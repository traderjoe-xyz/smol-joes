// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeArt} from "./ISmolJoeArt.sol";

/// @title Interface for SmolJoeSeeder
interface ISmolJoeSeeder {
    struct Seed {
        ISmolJoeArt.Brotherhood brotherhood;
        uint8 specialId;
        uint8 uniqueId;
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

    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor) external returns (Seed memory);
}
