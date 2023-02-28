// SPDX-License-Identifier: GPL-3.0

/// @title Interface for SmolJoeArt

pragma solidity ^0.8.6;

import {Inflate} from "../libs/Inflate.sol";
import {IInflator} from "./IInflator.sol";

interface ISmolJoeArt {
    error SenderIsNotDescriptor();

    error EmptyPalette();

    error BadPaletteLength();

    error EmptyBytes();

    error BadDecompressedLength();

    error BadImageCount();

    error ImageNotFound();

    error PaletteNotFound();

    event DescriptorUpdated(address oldDescriptor, address newDescriptor);

    event InflatorUpdated(address oldInflator, address newInflator);

    event BackgroundsAdded(uint256 count);

    event PaletteSet(uint8 paletteIndex);

    event BodiesAdded(uint16 count);

    event HeadsAdded(uint16 count);

    enum TraitType {
        Special,
        Backgrounds,
        Bodies,
        Pants,
        Shoes,
        Shirts,
        Beards,
        Heads,
        Eyes,
        Accessories
    }

    struct SmolJoeArtStoragePage {
        uint16 imageCount;
        uint80 decompressedLength;
        address pointer;
    }

    struct Trait {
        SmolJoeArtStoragePage[] storagePages;
        uint256 storedImagesCount;
    }

    function descriptor() external view returns (address);

    function inflator() external view returns (IInflator);

    function setDescriptor(address descriptor) external;

    function setInflator(IInflator inflator) external;

    function setPalette(uint8 paletteIndex, bytes calldata palette) external;

    function setPalettePointer(uint8 paletteIndex, address pointer) external;

    function palettes(uint8 paletteIndex) external view returns (bytes memory);

    function addTraits(
        TraitType traitType,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external;

    function addTraitsFromPointer(TraitType traitType, address pointer, uint80 decompressedLength, uint16 imageCount)
        external;

    function getTrait(TraitType traitType) external view returns (Trait memory);

    function specials(uint256 index) external view returns (bytes memory, string memory);

    function backgrounds(uint256 index) external view returns (bytes memory, string memory);

    function bodies(uint256 index) external view returns (bytes memory, string memory);

    function pants(uint256 index) external view returns (bytes memory, string memory);

    function shoes(uint256 index) external view returns (bytes memory, string memory);

    function shirts(uint256 index) external view returns (bytes memory, string memory);

    function beards(uint256 index) external view returns (bytes memory, string memory);

    function heads(uint256 index) external view returns (bytes memory, string memory);

    function eyes(uint256 index) external view returns (bytes memory, string memory);

    function accessories(uint256 index) external view returns (bytes memory, string memory);
}
