// SPDX-License-Identifier: GPL-3.0

/// @title The Smol Joe NFT descriptor
/// Inspired by Nouns DAO's NounsDescriptor contract

pragma solidity ^0.8.6;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ISmolJoeDescriptor} from "./interfaces/ISmolJoeDescriptor.sol";
import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {NFTDescriptor} from "./libs/NFTDescriptor.sol";
import {ISVGRenderer} from "./interfaces/ISVGRenderer.sol";
import {ISmolJoeArt} from "./interfaces/ISmolJoeArt.sol";
import {IInflator} from "./interfaces/IInflator.sol";

contract SmolJoeDescriptor is ISmolJoeDescriptor, Ownable {
    using Strings for uint256;

    /// @notice The contract responsible for holding compressed Smol Joe art
    ISmolJoeArt public art;

    /// @notice The contract responsible for constructing SVGs
    ISVGRenderer public renderer;

    /// @notice Whether or not `tokenURI` should be returned as a data URI (Default: true)
    bool public override isDataURIEnabled = true;

    /// @notice Base URI, used when isDataURIEnabled is false
    string public override baseURI;

    constructor(ISmolJoeArt _art, ISVGRenderer _renderer) {
        art = _art;
        renderer = _renderer;
    }

    /**
     * @notice Set the SmolJoe's art contract.
     * @dev Only callable by the owner.
     */
    function setArt(ISmolJoeArt _art) external onlyOwner {
        art = _art;

        emit ArtUpdated(_art);
    }

    /**
     * @notice Set the SVG renderer.
     * @dev Only callable by the owner.
     */
    function setRenderer(ISVGRenderer _renderer) external onlyOwner {
        renderer = _renderer;

        emit RendererUpdated(_renderer);
    }

    /**
     * @notice Set the art contract's `descriptor`.
     * @param descriptor the address to set.
     * @dev Only callable by the owner.
     */
    function setArtDescriptor(address descriptor) external onlyOwner {
        art.setDescriptor(descriptor);
    }

    /**
     * @notice Set the art contract's `inflator`.
     * @param inflator the address to set.
     * @dev Only callable by the owner.
     */
    function setArtInflator(IInflator inflator) external onlyOwner {
        art.setInflator(inflator);
    }

    function traitCount(ISmolJoeArt.TraitType traitType) external view override returns (uint256) {
        return art.getTrait(traitType).storedImagesCount;
    }

    /**
     * @notice Update a single color palette. This function can be used to
     * add a new color palette or update an existing palette.
     * @param paletteIndex the identifier of this palette
     * @param palette byte array of colors. every 3 bytes represent an RGB color. max length: 16**4 * 3 = 196_608
     * @dev This function can only be called by the owner.
     */
    function setPalette(uint8 paletteIndex, bytes calldata palette) external override onlyOwner {
        art.setPalette(paletteIndex, palette);
    }

    function addTraits(
        ISmolJoeArt.TraitType traitType,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyOwner {
        art.addTraits(traitType, encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Update a single color palette. This function can be used to
     * add a new color palette or update an existing palette. This function does not check for data length validity
     * (len <= 768, len % 3 == 0).
     * @param paletteIndex the identifier of this palette
     * @param pointer the address of the contract holding the palette bytes. every 3 bytes represent an RGB color.
     * max length: 256 * 3 = 768.
     * @dev This function can only be called by the owner.
     */
    function setPalettePointer(uint8 paletteIndex, address pointer) external override onlyOwner {
        art.setPalettePointer(paletteIndex, pointer);
    }

    function addTraitsFromPointer(
        ISmolJoeArt.TraitType traitType,
        address pointer,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyOwner {
        art.addTraitsFromPointer(traitType, pointer, decompressedLength, imageCount);
    }

    /**
     * @notice Get a specal image by ID.
     * @param index the index of the special.
     * @return string the RLE-encoded bytes value of the background.
     */
    function specials(uint256 index) public view override returns (bytes memory, string memory) {
        return art.specials(index);
    }

    /**
     * @notice Get a background image by ID.
     * @param index the index of the background.
     * @return string the RLE-encoded bytes value of the background.
     */
    function backgrounds(uint256 index) public view override returns (bytes memory, string memory) {
        return art.backgrounds(index);
    }

    /**
     * @notice Get a body image by ID.
     * @param index the index of the body.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function bodies(uint256 index) public view override returns (bytes memory, string memory) {
        return art.bodies(index);
    }

    /**
     * @notice Get a pant image by ID.
     * @param index the index of the body.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function pants(uint256 index) public view override returns (bytes memory, string memory) {
        return art.pants(index);
    }

    /**
     * @notice Get an shoe image by ID.
     * @param index the index of the eye.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function shoes(uint256 index) public view override returns (bytes memory, string memory) {
        return art.shoes(index);
    }

    /**
     * @notice Get a shirt image by ID.
     * @param index the index of the shirt.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function shirts(uint256 index) public view override returns (bytes memory, string memory) {
        return art.shirts(index);
    }

    /**
     * @notice Get a beard image by ID.
     * @param index the index of the beard.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function beards(uint256 index) public view override returns (bytes memory, string memory) {
        return art.beards(index);
    }

    /**
     * @notice Get a head image by ID.
     * @param index the index of the head.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function heads(uint256 index) public view override returns (bytes memory, string memory) {
        return art.heads(index);
    }

    /**
     * @notice Get an eye image by ID.
     * @param index the index of the eye.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function eyes(uint256 index) public view override returns (bytes memory, string memory) {
        return art.eyes(index);
    }

    /**
     * @notice Get an accessory image by ID.
     * @param index the index of the accessory.
     * @return bytes the RLE-encoded bytes of the image.
     */
    function accessories(uint256 index) public view override returns (bytes memory, string memory) {
        return art.accessories(index);
    }

    /**
     * @notice Get a color palette by ID.
     * @param index the index of the palette.
     * @return bytes the palette bytes, where every 3 consecutive bytes represent a color in RGB format.
     */
    function palettes(uint8 index) public view override returns (bytes memory) {
        return art.palettes(index);
    }

    /**
     * @notice Toggle a boolean value which determines if `tokenURI` returns a data URI
     * or an HTTP URL.
     * @dev This can only be called by the owner.
     */
    function toggleDataURIEnabled() external override onlyOwner {
        bool enabled = !isDataURIEnabled;

        isDataURIEnabled = enabled;
        emit DataURIToggled(enabled);
    }

    /**
     * @notice Set the base URI for all token IDs. It is automatically
     * added as a prefix to the value returned in {tokenURI}, or to the
     * token ID if {tokenURI} is empty.
     * @dev This can only be called by the owner.
     */
    function setBaseURI(string calldata _baseURI) external override onlyOwner {
        baseURI = _baseURI;

        emit BaseURIUpdated(_baseURI);
    }

    /**
     * @notice Given a token ID and seed, construct a token URI for an official Nouns DAO noun.
     * @dev The returned value may be a base64 encoded data URI or an API URL.
     */
    function tokenURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed)
        external
        view
        override
        returns (string memory)
    {
        if (isDataURIEnabled) {
            return dataURI(tokenId, seed);
        }
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    /**
     * @notice Given a token ID and seed, construct a base64 encoded data URI for an official Nouns DAO noun.
     */
    function dataURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed) public view override returns (string memory) {
        string memory joeId = tokenId.toString();
        string memory name = string(abi.encodePacked("Smol Joe ", joeId));
        string memory description = string(abi.encodePacked("This is a empty description"));

        return genericDataURI(name, description, seed);
    }

    /**
     * @notice Given a name, description, and seed, construct a base64 encoded data URI.
     */
    function genericDataURI(string memory name, string memory description, ISmolJoeSeeder.Seed memory seed)
        public
        view
        override
        returns (string memory)
    {
        NFTDescriptor.TokenURIParams memory params =
            NFTDescriptor.TokenURIParams({name: name, description: description, parts: getPartsForSeed(seed)});
        return NFTDescriptor.constructTokenURI(renderer, params);
    }

    /**
     * @notice Given a seed, construct a base64 encoded SVG image.
     */
    function generateSVGImage(ISmolJoeSeeder.Seed memory seed) external view override returns (string memory) {
        ISVGRenderer.SVGParams memory params = ISVGRenderer.SVGParams({parts: getPartsForSeed(seed)});
        return NFTDescriptor.generateSVGImage(renderer, params);
    }

    /**
     * @notice Get all Smol Joe parts for the passed `seed`.
     */
    function getPartsForSeed(ISmolJoeSeeder.Seed memory seed) public view returns (ISVGRenderer.Part[] memory) {
        if (seed.smolJoeType == ISmolJoeSeeder.SmolJoeCast.Special) {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](1);
            (bytes memory special, string memory specialTraitName) = art.specials(0);

            parts[0] = ISVGRenderer.Part({name: specialTraitName, image: special, palette: _getPalette(special)});
            return parts;
        } else {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](9);

            {
                (bytes memory background, string memory backgroundTraitName) = art.backgrounds(seed.background);
                (bytes memory body, string memory bodyTraitName) = art.bodies(seed.body);
                (bytes memory pant, string memory pantTraitName) = art.pants(seed.pant);
                (bytes memory shoe, string memory shoeTraitName) = art.shoes(seed.shoe);

                parts[0] =
                    ISVGRenderer.Part({name: backgroundTraitName, image: background, palette: _getPalette(background)});
                parts[1] = ISVGRenderer.Part({name: bodyTraitName, image: body, palette: _getPalette(body)});
                parts[2] = ISVGRenderer.Part({name: pantTraitName, image: pant, palette: _getPalette(pant)});
                parts[3] = ISVGRenderer.Part({name: shoeTraitName, image: shoe, palette: _getPalette(shoe)});
            }

            {
                (bytes memory shirt, string memory shirtTraitName) = art.shirts(seed.shirt);
                (bytes memory beard, string memory beardTraitName) = art.beards(seed.beard);
                (bytes memory head, string memory headTraitName) = art.heads(seed.head);
                (bytes memory eye, string memory eyeTraitName) = art.eyes(seed.eye);
                (bytes memory accessory, string memory accessoryTraitName) = art.accessories(seed.accessory);

                parts[4] = ISVGRenderer.Part({name: shirtTraitName, image: shirt, palette: _getPalette(shirt)});
                parts[5] = ISVGRenderer.Part({name: beardTraitName, image: beard, palette: _getPalette(beard)});
                parts[6] = ISVGRenderer.Part({name: headTraitName, image: head, palette: _getPalette(head)});
                parts[7] = ISVGRenderer.Part({name: eyeTraitName, image: eye, palette: _getPalette(eye)});
                parts[8] =
                    ISVGRenderer.Part({name: accessoryTraitName, image: accessory, palette: _getPalette(accessory)});
            }
            return parts;
        }
    }

    /**
     * @notice Get the color palette pointer for the passed part.
     */
    function _getPalette(bytes memory part) private view returns (bytes memory) {
        return art.palettes(uint8(part[0]));
    }
}
