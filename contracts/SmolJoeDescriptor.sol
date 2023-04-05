// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ISmolJoeDescriptor} from "./interfaces/ISmolJoeDescriptor.sol";
import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {NFTDescriptor} from "./libs/NFTDescriptor.sol";
import {ISVGRenderer} from "./interfaces/ISVGRenderer.sol";
import {ISmolJoeArt} from "./interfaces/ISmolJoeArt.sol";
import {IInflator} from "./interfaces/IInflator.sol";

/// @title The Smol Joe NFT descriptor
/// @notice Based on NounsDAO: https://github.com/nounsDAO/nouns-monorepo
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

    function traitCount(ISmolJoeArt.TraitType traitType, ISmolJoeArt.Brotherhood brotherhood)
        external
        view
        override
        returns (uint256)
    {
        return art.getTrait(traitType, brotherhood).storedImagesCount;
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

    function addTraits(
        ISmolJoeArt.TraitType traitType,
        ISmolJoeArt.Brotherhood brotherhood,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyOwner {
        art.addTraits(traitType, brotherhood, encodedCompressed, decompressedLength, imageCount);
    }

    function addMultipleTraits(
        ISmolJoeArt.TraitType[] calldata traitType,
        ISmolJoeArt.Brotherhood[] calldata brotherhood,
        bytes[] calldata encodedCompressed,
        uint80[] calldata decompressedLength,
        uint16[] calldata imageCount
    ) external override onlyOwner {
        for (uint256 i = 0; i < traitType.length; i++) {
            art.addTraits(traitType[i], brotherhood[i], encodedCompressed[i], decompressedLength[i], imageCount[i]);
        }
    }

    function addTraitsFromPointer(
        ISmolJoeArt.TraitType traitType,
        ISmolJoeArt.Brotherhood brotherhood,
        address pointer,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyOwner {
        art.addTraitsFromPointer(traitType, brotherhood, pointer, decompressedLength, imageCount);
    }

    function addMultipleTraitsFromPointer(
        ISmolJoeArt.TraitType[] calldata traitType,
        ISmolJoeArt.Brotherhood[] calldata brotherhood,
        address[] calldata pointer,
        uint80[] calldata decompressedLength,
        uint16[] calldata imageCount
    ) external override onlyOwner {
        for (uint256 i = 0; i < traitType.length; i++) {
            art.addTraitsFromPointer(traitType[i], brotherhood[i], pointer[i], decompressedLength[i], imageCount[i]);
        }
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
     * @notice Given a token ID and seed, construct a token URI for a Smol Joe.
     * @dev The returned value may be a base64 encoded data URI or an API URL.
     */
    function tokenURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed)
        external
        view
        override
        returns (string memory)
    {
        if (isDataURIEnabled) {
            return _dataURI(tokenId, seed);
        }
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    /**
     * @notice Given a token ID and seed, construct a base64 encoded data URI for a Smol Joe.
     */
    function dataURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed) external view override returns (string memory) {
        return _dataURI(tokenId, seed);
    }

    /**
     * @notice Given a name, description, and seed, construct a base64 encoded data URI.
     */
    function genericDataURI(string memory name, string memory description, ISmolJoeSeeder.Seed memory seed)
        external
        view
        override
        returns (string memory)
    {
        return _genericDataURI(name, description, seed);
    }

    /**
     * @notice Given a seed, construct a base64 encoded SVG image.
     */
    function generateSVGImage(ISmolJoeSeeder.Seed memory seed) external view override returns (string memory) {
        ISVGRenderer.SVGParams memory params = ISVGRenderer.SVGParams({parts: _getPartsForSeed(seed)});
        return NFTDescriptor.generateSVGImage(renderer, params);
    }

    /**
     * @dev Given a token ID and seed, construct a base64 encoded data URI for a Smol Joe.
     */
    function _dataURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed) internal view returns (string memory) {
        string memory name;
        if (tokenId >= 200) {
            string memory joeId = tokenId.toString();
            name = string(abi.encodePacked("Smol Joe ", joeId));
        }
        string memory description = string(abi.encodePacked("This is an empty description"));

        return _genericDataURI(name, description, seed);
    }

    /**
     * @dev Given a name, description, and seed, construct a base64 encoded data URI.
     */
    function _genericDataURI(string memory name, string memory description, ISmolJoeSeeder.Seed memory seed)
        internal
        view
        returns (string memory)
    {
        NFTDescriptor.TokenURIParams memory params = NFTDescriptor.TokenURIParams({
            name: name,
            description: description,
            parts: _getPartsForSeed(seed),
            brotherhood: seed.brotherhood
        });

        // The Uniques and the Luminaries are named after the name of their attribute.
        if (bytes(name).length == 0) {
            params.name = params.parts[0].name;
        }

        return NFTDescriptor.constructTokenURI(renderer, params);
    }

    /**
     * @notice Get all Smol Joe parts for the passed `seed`.
     */
    function _getPartsForSeed(ISmolJoeSeeder.Seed memory seed) internal view returns (ISVGRenderer.Part[] memory) {
        if (seed.specialId > 0) {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](1);
            (bytes memory special, string memory specialTraitName) =
                art.getImageByIndex(ISmolJoeArt.TraitType.Special, ISmolJoeArt.Brotherhood.None, seed.specialId - 1);

            parts[0] = ISVGRenderer.Part({name: specialTraitName, image: special, palette: _getPalette(special)});
            return parts;
        } else if (seed.uniqueId > 0) {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](1);
            (bytes memory special, string memory specialTraitName) =
                art.getImageByIndex(ISmolJoeArt.TraitType.Unique, seed.brotherhood, seed.uniqueId - 1);

            parts[0] = ISVGRenderer.Part({name: specialTraitName, image: special, palette: _getPalette(special)});
            return parts;
        } else {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](9);

            {
                (bytes memory background, string memory backgroundTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Background, ISmolJoeArt.Brotherhood.None, seed.background);
                (bytes memory body, string memory bodyTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Body, ISmolJoeArt.Brotherhood.None, seed.body);
                (bytes memory shoe, string memory shoeTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Shoes, ISmolJoeArt.Brotherhood.None, seed.shoe);

                parts[0] =
                    ISVGRenderer.Part({name: backgroundTraitName, image: background, palette: _getPalette(background)});
                parts[1] = ISVGRenderer.Part({name: bodyTraitName, image: body, palette: _getPalette(body)});
                parts[2] = ISVGRenderer.Part({name: shoeTraitName, image: shoe, palette: _getPalette(shoe)});
            }

            {
                (bytes memory pant, string memory pantTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Pants, ISmolJoeArt.Brotherhood.None, seed.pant);
                (bytes memory shirt, string memory shirtTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Shirt, ISmolJoeArt.Brotherhood.None, seed.shirt);
                (bytes memory beard, string memory beardTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Beard, ISmolJoeArt.Brotherhood.None, seed.beard);

                parts[3] = ISVGRenderer.Part({name: pantTraitName, image: pant, palette: _getPalette(pant)});
                parts[4] = ISVGRenderer.Part({name: shirtTraitName, image: shirt, palette: _getPalette(shirt)});
                parts[5] = ISVGRenderer.Part({name: beardTraitName, image: beard, palette: _getPalette(beard)});
            }

            {
                (bytes memory head, string memory headTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.HairCapHead, ISmolJoeArt.Brotherhood.None, seed.head);
                (bytes memory eye, string memory eyeTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.EyeAccessory, ISmolJoeArt.Brotherhood.None, seed.eye);
                (bytes memory accessory, string memory accessoryTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Accessories, ISmolJoeArt.Brotherhood.None, seed.accessory);

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
