// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {IInflator} from "./IInflator.sol";

/**
 * @title Interface for SmolJoeArt
 */
interface ISmolJoeArt {
    error SmolJoeArt__SenderIsNotDescriptor();
    error SmolJoeArt__EmptyPalette();
    error SmolJoeArt__BadPaletteLength();
    error SmolJoeArt__EmptyBytes();
    error SmolJoeArt__BadDecompressedLength();
    error SmolJoeArt__BadImageCount();
    error SmolJoeArt__PaletteNotFound();
    error SmolJoeArt__ImageNotFound();
    error SmolJoeArt__InvalidAddress();
    error SmolJoeArt__DecompressionError(uint8 errorCode);

    event DescriptorUpdated(address newDescriptor);
    event InflatorUpdated(address newInflator);
    event PaletteSet(uint8 paletteIndex);
    event HouseEmblemSet(Brotherhood brotherhood, address pointer);
    event HouseGlowingEmblemSet(Brotherhood brotherhood, address pointer);
    event LuminariesMetadataSet(Brotherhood brotherhood, address pointer);

    enum TraitType {
        Original,
        Luminary,
        Background,
        Body,
        Shoes,
        Pants,
        Shirt,
        Beard,
        HairCapHead,
        EyeAccessory,
        Accessories
    }

    enum Brotherhood {
        None,
        Academics,
        Athletes,
        Creatives,
        Gentlemans,
        Heroes,
        MagicalBeings,
        Musicians,
        Outlaws,
        Warriors,
        Worshipers
    }

    /**
     * @dev Struct describing a page of RLE encoded images
     * @param imageCount Number of images
     * @param decompressedLength Length of the data once decompressed
     * @param pointer Address of the page
     */
    struct SmolJoeArtStoragePage {
        uint16 imageCount;
        uint80 decompressedLength;
        address pointer;
    }

    /**
     * @dev Struct describing a trait
     * @param storagePages Array of pages
     * @param storedImagesCount Total number of images
     */
    struct Trait {
        SmolJoeArtStoragePage[] storagePages;
        uint256 storedImagesCount;
    }

    function descriptor() external view returns (address);

    function inflator() external view returns (IInflator);

    function palettesPointers(uint8 paletteIndex) external view returns (address);

    function getTrait(TraitType traitType, Brotherhood brotherhood) external view returns (Trait memory);

    function getImageByIndex(TraitType traitType, Brotherhood brotherhood, uint256 index)
        external
        view
        returns (bytes memory rle, string memory name);

    function getHouseEmblem(Brotherhood brotherhood) external view returns (string memory svg);

    function getGlowingHouseEmblem(Brotherhood brotherhood) external view returns (string memory svg);

    function getLuminariesMetadata(Brotherhood brotherhood) external view returns (bytes[] memory);

    function palettes(uint8 paletteIndex) external view returns (bytes memory);

    function setDescriptor(address descriptor) external;

    function setInflator(IInflator inflator) external;

    function setPalette(uint8 paletteIndex, bytes calldata palette) external;

    function setPalettePointer(uint8 paletteIndex, address pointer) external;

    function setHouseEmblem(Brotherhood brotherhood, string calldata svgString) external;

    function setHouseEmblemPointer(Brotherhood brotherhood, address pointer) external;

    function setGlowingHouseEmblem(ISmolJoeArt.Brotherhood brotherhood, string calldata svgString) external;

    function setGlowingHouseEmblemPointer(ISmolJoeArt.Brotherhood brotherhood, address pointer) external;

    function setLuminariesMetadata(Brotherhood brotherhood, bytes calldata metadatas) external;

    function setLuminariesMetadataPointer(Brotherhood brotherhood, address pointer) external;

    function addTraits(
        TraitType traitType,
        Brotherhood brotherhood,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external;

    function addTraitsFromPointer(
        TraitType traitType,
        Brotherhood brotherhood,
        address pointer,
        uint80 decompressedLength,
        uint16 imageCount
    ) external;
}
