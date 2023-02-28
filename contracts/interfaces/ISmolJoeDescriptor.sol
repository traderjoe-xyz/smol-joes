// SPDX-License-Identifier: GPL-3.0

/// @title Interface for SmolJoeDescriptor

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";
import {ISVGRenderer} from "./ISVGRenderer.sol";
import {ISmolJoeArt} from "./ISmolJoeArt.sol";
import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";

interface ISmolJoeDescriptor is ISmolJoeDescriptorMinimal {
    event PartsLocked();

    event DataURIToggled(bool enabled);

    event BaseURIUpdated(string baseURI);

    event ArtUpdated(ISmolJoeArt art);

    event RendererUpdated(ISVGRenderer renderer);

    error EmptyPalette();
    error BadPaletteLength();
    error IndexNotFound();

    function isDataURIEnabled() external returns (bool);

    function baseURI() external returns (string memory);

    function palettes(uint8 paletteIndex) external view returns (bytes memory);

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

    function traitCount(ISmolJoeArt.TraitType traitType) external view returns (uint256);

    function setPalette(uint8 paletteIndex, bytes calldata palette) external;

    function addTraits(
        ISmolJoeArt.TraitType traitType,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external;

    function setPalettePointer(uint8 paletteIndex, address pointer) external;

    function addTraitsFromPointer(
        ISmolJoeArt.TraitType traitType,
        address pointer,
        uint80 decompressedLength,
        uint16 imageCount
    ) external;

    function toggleDataURIEnabled() external;

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
}
