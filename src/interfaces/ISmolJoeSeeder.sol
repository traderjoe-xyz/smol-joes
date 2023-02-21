// SPDX-License-Identifier: GPL-3.0

/// @title Interface for SmolJoeSeeder

pragma solidity ^0.8.6;

import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";

interface ISmolJoeSeeder {
    struct Seed {
        uint48 background;
        uint48 body;
        uint48 head;
    }

    function generateSeed(uint256 nounId, ISmolJoeDescriptorMinimal descriptor) external view returns (Seed memory);
}
