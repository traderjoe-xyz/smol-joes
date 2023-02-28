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

    function palettes(uint8 paletteIndex) external view returns (bytes memory);

    function setPalette(uint8 paletteIndex, bytes calldata palette) external;

    function addBackgrounds(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addBodies(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addPants(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addShoes(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addShirts(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addBeards(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addHeads(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addEyes(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function addAccessories(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount) external;

    function setPalettePointer(uint8 paletteIndex, address pointer) external;

    function addBackgroundsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addBodiesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addPantsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addShoesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addShirtsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addBeardsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addHeadsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addEyesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function addAccessoriesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount) external;

    function backgrounds(uint256 index) external view returns (bytes memory, string memory);

    function bodies(uint256 index) external view returns (bytes memory, string memory);

    function pants(uint256 index) external view returns (bytes memory, string memory);

    function shoes(uint256 index) external view returns (bytes memory, string memory);

    function shirts(uint256 index) external view returns (bytes memory, string memory);

    function beards(uint256 index) external view returns (bytes memory, string memory);

    function heads(uint256 index) external view returns (bytes memory, string memory);

    function eyes(uint256 index) external view returns (bytes memory, string memory);

    function accessories(uint256 index) external view returns (bytes memory, string memory);

    function getBackgroundsTrait() external view returns (Trait memory);

    function getBodiesTrait() external view returns (Trait memory);

    function getPantsTrait() external view returns (Trait memory);

    function getShoesTrait() external view returns (Trait memory);

    function getShirtsTrait() external view returns (Trait memory);

    function getBeardsTrait() external view returns (Trait memory);

    function getHeadsTrait() external view returns (Trait memory);

    function getEyesTrait() external view returns (Trait memory);

    function getAccessoriesTrait() external view returns (Trait memory);
}
