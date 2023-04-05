// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {Inflate} from "../libs/Inflate.sol";
import {IInflator} from "./IInflator.sol";

/// @title Interface for SmolJoeArt
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
        Unique,
        Background,
        Body,
        Pants,
        Shoes,
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
        MagicalBeings,
        Military,
        Musicians,
        Outlaws,
        Religious,
        Superheros
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

    function getTrait(TraitType traitType, Brotherhood brotherhood) external view returns (Trait memory);

    function getImageByIndex(TraitType traitType, Brotherhood brotherhood, uint256 index)
        external
        view
        returns (bytes memory rle, string memory name);
}
