// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeArt} from "./ISmolJoeArt.sol";

/**
 * @title Interface for SmolJoeSeeder
 */
interface ISmolJoeSeeder {
    error SmolJoeSeeder__InvalidAddress();
    error SmolJoeSeeder__OnlySmolJoes();

    event OriginalsArtMappingUpdated(uint8[100] originalsArtMapping);
    event SmolJoesAddressSet(address smolJoesAddress);
    /**
     * @dev Struct describing all parts of a Smol Joe
     * Originals and Specials are described by their ID
     * Commons are described by all their body parts
     */

    struct Seed {
        ISmolJoeArt.Brotherhood brotherhood;
        uint8 originalId;
        uint8 luminaryId;
        uint16 background;
        uint16 body;
        uint16 shoes;
        uint16 pants;
        uint16 shirt;
        uint16 beard;
        uint16 hairCapHead;
        uint16 eyeAccessory;
        uint16 accessory;
    }

    function smolJoes() external view returns (address);

    function getOriginalsArtMapping(uint256 index) external view returns (uint8);

    function updateOriginalsArtMapping(uint8[100] calldata artMapping) external;

    function setSmolJoesAddress(address _smolJoes) external;

    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor) external returns (Seed memory);
}
