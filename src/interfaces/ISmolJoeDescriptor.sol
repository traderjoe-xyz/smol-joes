// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {IInflator} from "./IInflator.sol";
import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";
import {ISVGRenderer} from "./ISVGRenderer.sol";
import {ISmolJoeArt} from "./ISmolJoeArt.sol";
import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";

/**
 * @title Interface for SmolJoeDescriptor
 */
interface ISmolJoeDescriptor is ISmolJoeDescriptorMinimal {
    error SmolJoeDescriptor__InvalidAddress();
    error SmolJoeDescriptor__UpdateToSameState();

    event DataURIToggled(bool enabled);
    event BaseURIUpdated(string baseURI);
    event ArtUpdated(ISmolJoeArt art);
    event RendererUpdated(ISVGRenderer renderer);

    function art() external returns (ISmolJoeArt);

    function renderer() external returns (ISVGRenderer);

    function isDataURIEnabled() external returns (bool);

    function baseURI() external returns (string memory);

    function setArt(ISmolJoeArt art) external;

    function setRenderer(ISVGRenderer renderer) external;

    function setArtDescriptor(address descriptor) external;

    function setArtInflator(IInflator inflator) external;

    function setDataURIEnabled(bool isEnabled) external;

    function setBaseURI(string calldata baseURI) external;

    function tokenURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed)
        external
        view
        override
        returns (string memory);

    function dataURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed) external view override returns (string memory);

    function genericDataURI(string calldata name, string calldata description, ISmolJoeSeeder.Seed memory seed)
        external
        view
        returns (string memory);

    function generateSVGImage(ISmolJoeSeeder.Seed memory seed) external view returns (string memory);

    function palettes(uint8 paletteIndex) external view returns (bytes memory);

    function traitCount(ISmolJoeArt.TraitType traitType, ISmolJoeArt.Brotherhood brotherhood)
        external
        view
        returns (uint256);

    function setPalette(uint8 paletteIndex, bytes calldata palette) external;

    function setPalettePointer(uint8 paletteIndex, address pointer) external;

    function setHouseEmblem(ISmolJoeArt.Brotherhood brotherhood, string calldata svgString) external;

    function setHouseEmblemPointer(ISmolJoeArt.Brotherhood brotherhood, address pointer) external;

    function setGlowingHouseEmblem(ISmolJoeArt.Brotherhood brotherhood, string calldata svgString) external;

    function setGlowingHouseEmblemPointer(ISmolJoeArt.Brotherhood brotherhood, address pointer) external;

    function setLuminariesMetadata(ISmolJoeArt.Brotherhood brotherhood, bytes calldata metadatas) external;

    function setLuminariesMetadataPointer(ISmolJoeArt.Brotherhood brotherhood, address pointer) external;

    function addTraits(
        ISmolJoeArt.TraitType traitType,
        ISmolJoeArt.Brotherhood brotherhood,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external;

    function addTraitsFromPointer(
        ISmolJoeArt.TraitType traitType,
        ISmolJoeArt.Brotherhood brotherhood,
        address pointer,
        uint80 decompressedLength,
        uint16 imageCount
    ) external;

    function addMultipleTraits(
        ISmolJoeArt.TraitType[] calldata traitType,
        ISmolJoeArt.Brotherhood[] calldata brotherhood,
        bytes[] calldata encodedCompressed,
        uint80[] calldata decompressedLength,
        uint16[] calldata imageCount
    ) external;

    function addMultipleTraitsFromPointer(
        ISmolJoeArt.TraitType[] calldata traitType,
        ISmolJoeArt.Brotherhood[] calldata brotherhood,
        address[] calldata pointer,
        uint80[] calldata decompressedLength,
        uint16[] calldata imageCount
    ) external;
}
