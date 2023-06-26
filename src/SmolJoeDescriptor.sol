// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {Strings} from "openzeppelin/utils/Strings.sol";
import {ISmolJoeDescriptor} from "./interfaces/ISmolJoeDescriptor.sol";
import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {NFTDescriptor} from "./libs/NFTDescriptor.sol";
import {ISVGRenderer} from "./interfaces/ISVGRenderer.sol";
import {ISmolJoeArt} from "./interfaces/ISmolJoeArt.sol";
import {IInflator} from "./interfaces/IInflator.sol";

/**
 * @title The Smol Joe NFT descriptor
 * @notice Based on NounsDAO: https://github.com/nounsDAO/nouns-monorepo
 */
contract SmolJoeDescriptor is Ownable2Step, ISmolJoeDescriptor {
    using Strings for uint256;

    /**
     * @notice The contract responsible for holding compressed Smol Joe art
     */
    ISmolJoeArt public override art;

    /**
     * @notice The contract responsible for constructing SVGs
     */
    ISVGRenderer public override renderer;

    /**
     * @notice Whether or not `tokenURI` should be returned as a data URI (Default: true)
     */
    bool public override isDataURIEnabled;

    /**
     * @notice Base URI, used when isDataURIEnabled is false
     */
    string public override baseURI;

    constructor(ISmolJoeArt _art, ISVGRenderer _renderer) {
        _setArt(_art);
        _setRenderer(_renderer);
        _setDataURIEnabled(true);
    }

    /**
     * @notice Set the SmolJoe's art contract.
     * @param _art the address of the art contract.
     */
    function setArt(ISmolJoeArt _art) external override onlyOwner {
        _setArt(_art);
    }

    /**
     * @notice Set the SVG renderer.
     * @param _renderer the address of the renderer contract.
     */
    function setRenderer(ISVGRenderer _renderer) external override onlyOwner {
        _setRenderer(_renderer);
    }

    /**
     * @notice Set the art contract's `descriptor`.
     * @param descriptor the address to set.
     */
    function setArtDescriptor(address descriptor) external override onlyOwner {
        art.setDescriptor(descriptor);
    }

    /**
     * @notice Set the art contract's `inflator`.
     * @param inflator the address to set.
     */
    function setArtInflator(IInflator inflator) external override onlyOwner {
        art.setInflator(inflator);
    }

    /**
     * @notice Toggle a boolean value which determines if `tokenURI` returns a data URI
     * or an HTTP URL.
     * @param isEnabled whether or not to enable data URIs.
     */
    function setDataURIEnabled(bool isEnabled) external override onlyOwner {
        _setDataURIEnabled(isEnabled);
    }

    /**
     * @notice Set the base URI for all token IDs. It is automatically
     * added as a prefix to the value returned in {tokenURI}, or to the
     * token ID if {tokenURI} is empty.
     * @param _baseURI the base URI to use.
     */
    function setBaseURI(string calldata _baseURI) external override onlyOwner {
        baseURI = _baseURI;

        emit BaseURIUpdated(_baseURI);
    }

    /**
     * @notice Given a token ID and seed, construct a token URI for a Smol Joe.
     * @dev The returned value may be a base64 encoded data URI or an API URL.
     * @param tokenId the token ID to construct the URI for.
     * @param seed the seed to use to construct the URI.
     * @return The token URI.
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
     * @param tokenId the token ID to construct the URI for.
     * @param seed the seed to use to construct the URI.
     * @return The base64 encoded data URI.
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
        ISVGRenderer.SVGParams memory params = ISVGRenderer.SVGParams({
            parts: _getPartsForSeed(seed),
            emblem: seed.luminaryId == 0 && seed.originalId == 0 ? art.getHouseEmblem(seed.brotherhood) : "",
            glowingEmblem: seed.luminaryId > 0 ? art.getGlowingHouseEmblem(seed.brotherhood) : ""
        });
        return NFTDescriptor.generateSVGImage(renderer, params);
    }

    /**
     * @notice Get the trait count for a given trait type and brotherhood.
     * @param traitType the trait type to get the count for.
     * @param brotherhood the brotherhood to get the count for.
     * @return The trait count.
     */
    function traitCount(ISmolJoeArt.TraitType traitType, ISmolJoeArt.Brotherhood brotherhood)
        external
        view
        override
        returns (uint256)
    {
        return art.getTrait(traitType, brotherhood).storedImagesCount;
    }

    /**
     * @notice Get a color palette by ID.
     * @param index the index of the palette.
     * @return bytes the palette bytes, where every 3 consecutive bytes represent a color in RGB format.
     */
    function palettes(uint8 index) external view override returns (bytes memory) {
        return art.palettes(index);
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

    /**
     * @notice Set the house emblem for a given brotherhood.
     * @param brotherhood The brotherhood
     * @param svgString The Base 64 encoded SVG string
     */
    function setHouseEmblem(ISmolJoeArt.Brotherhood brotherhood, string calldata svgString)
        external
        override
        onlyOwner
    {
        art.setHouseEmblem(brotherhood, svgString);
    }

    /**
     * @notice Set the house emblem for a given brotherhood.
     * @param brotherhood The brotherhood
     * @param pointer The address of the contract holding the Base 64 encoded SVG string
     */
    function setHouseEmblemPointer(ISmolJoeArt.Brotherhood brotherhood, address pointer) external override onlyOwner {
        art.setHouseEmblemPointer(brotherhood, pointer);
    }

    /**
     * @notice Set the glowing house emblem for a given brotherhood.
     * @param brotherhood The brotherhood
     * @param svgString The Base 64 encoded SVG string
     */
    function setGlowingHouseEmblem(ISmolJoeArt.Brotherhood brotherhood, string calldata svgString)
        external
        override
        onlyOwner
    {
        art.setGlowingHouseEmblem(brotherhood, svgString);
    }

    /**
     * @notice Set the glowing house emblem for a given brotherhood.
     * @param brotherhood The brotherhood
     * @param pointer The address of the contract holding the Base 64 encoded SVG string
     */
    function setGlowingHouseEmblemPointer(ISmolJoeArt.Brotherhood brotherhood, address pointer)
        external
        override
        onlyOwner
    {
        art.setGlowingHouseEmblemPointer(brotherhood, pointer);
    }

    /**
     * @notice Set the luminaries metadata for a given brotherhood.
     * @param brotherhood The brotherhood
     * @param metadatas The metadata array, abi encoded
     */
    function setLuminariesMetadata(ISmolJoeArt.Brotherhood brotherhood, bytes calldata metadatas)
        external
        override
        onlyOwner
    {
        art.setLuminariesMetadata(brotherhood, metadatas);
    }

    /**
     * @notice Set the house emblem for a given brotherhood.
     * @param brotherhood The brotherhood
     * @param pointer The address of the contract holding the metadata array
     */
    function setLuminariesMetadataPointer(ISmolJoeArt.Brotherhood brotherhood, address pointer)
        external
        override
        onlyOwner
    {
        art.setLuminariesMetadataPointer(brotherhood, pointer);
    }

    /**
     * @notice Add a new page of RLE encoded images to a trait.
     * @param traitType The trait type
     * @param brotherhood The brotherhood
     * @param encodedCompressed The RLE encoded compressed data
     * @param decompressedLength The length of the data once decompressed
     * @param imageCount The number of images in the page
     */
    function addTraits(
        ISmolJoeArt.TraitType traitType,
        ISmolJoeArt.Brotherhood brotherhood,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyOwner {
        art.addTraits(traitType, brotherhood, encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Add a new page of RLE encoded images to a trait. The page has already been deployed to a contract.
     * @param traitType The trait type
     * @param brotherhood The brotherhood
     * @param pointer The address of the contract holding the RLE encoded compressed data
     * @param decompressedLength The length of the data once decompressed
     * @param imageCount The number of images in the page
     */
    function addTraitsFromPointer(
        ISmolJoeArt.TraitType traitType,
        ISmolJoeArt.Brotherhood brotherhood,
        address pointer,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyOwner {
        art.addTraitsFromPointer(traitType, brotherhood, pointer, decompressedLength, imageCount);
    }

    /**
     * @notice Add multiple pages of RLE encoded images to a trait.
     * @param traitType The trait types
     * @param brotherhood The brotherhoods
     * @param encodedCompressed The RLE encoded compressed datas
     * @param decompressedLength The lengths of the data once decompressed
     * @param imageCount The numbers of images in the page
     */
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

    /**
     * @notice Add multiple pages of RLE encoded images to a trait. The pages have already been deployed to a contract.
     * @param traitType The trait types
     * @param brotherhood The brotherhoods
     * @param pointer The addresses of the contracts holding the RLE encoded compressed datas
     * @param decompressedLength The lengths of the data once decompressed
     * @param imageCount The numbers of images in the page
     */
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
     * @dev Given a token ID and seed, construct a base64 encoded data URI for a Smol Joe.
     * @param tokenId The token ID
     * @param seed The seed of the token
     * @return The data URI
     */
    function _dataURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed) internal view returns (string memory) {
        string memory name;
        if (tokenId >= 200) {
            string[10] memory brotherhoodNames = [
                "Academic",
                "Athlete",
                "Creative",
                "Gentleman",
                "Hero",
                "Magical Being",
                "Musician",
                "Outlaw",
                "Warrior",
                "Worshiper"
            ];

            string memory joeId = tokenId.toString();
            name = string(abi.encodePacked("Smol ", brotherhoodNames[uint8(seed.brotherhood) - 1], " #", joeId, " Joe"));
        }
        string memory description = string(abi.encodePacked("The Expansion of Smol Joes"));

        return _genericDataURI(name, description, seed);
    }

    /**
     * @dev Given a name, description, and seed, construct a base64 encoded data URI.
     * @param name The name of the token
     * @param description The description of the token
     * @param seed The seed of the token
     * @return The data URI
     */
    function _genericDataURI(string memory name, string memory description, ISmolJoeSeeder.Seed memory seed)
        internal
        view
        returns (string memory)
    {
        string memory metadata;
        if (seed.luminaryId > 0) {
            metadata = string(art.getLuminariesMetadata(seed.brotherhood)[seed.luminaryId - 1]);
        }

        NFTDescriptor.TokenURIParams memory params = NFTDescriptor.TokenURIParams({
            name: name,
            description: description,
            brotherhood: seed.brotherhood,
            emblem: seed.luminaryId == 0 && seed.originalId == 0 ? art.getHouseEmblem(seed.brotherhood) : "",
            glowingEmblem: seed.luminaryId > 0 ? art.getGlowingHouseEmblem(seed.brotherhood) : "",
            metadata: metadata,
            parts: _getPartsForSeed(seed)
        });

        // The Uniques and the Luminaries are named after the name of their attribute.
        if (bytes(name).length == 0) {
            params.name = params.parts[0].name;
        }

        return NFTDescriptor.constructTokenURI(renderer, params);
    }

    /**
     * @notice Get all Smol Joe parts for the passed `seed`.
     * @param seed The seed
     * @return The different parts of the Smol Joe
     */
    function _getPartsForSeed(ISmolJoeSeeder.Seed memory seed) internal view returns (ISVGRenderer.Part[] memory) {
        if (seed.originalId > 0) {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](1);
            (bytes memory original, string memory originalTraitName) =
                art.getImageByIndex(ISmolJoeArt.TraitType.Original, ISmolJoeArt.Brotherhood.None, seed.originalId - 1);

            parts[0] = ISVGRenderer.Part({name: originalTraitName, image: original, palette: _getPalette(original)});
            return parts;
        } else if (seed.luminaryId > 0) {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](1);
            (bytes memory luminary, string memory luminaryTraitName) =
                art.getImageByIndex(ISmolJoeArt.TraitType.Luminary, seed.brotherhood, seed.luminaryId - 1);

            parts[0] = ISVGRenderer.Part({name: luminaryTraitName, image: luminary, palette: _getPalette(luminary)});
            return parts;
        } else {
            ISVGRenderer.Part[] memory parts = new ISVGRenderer.Part[](9);

            {
                (bytes memory background, string memory backgroundTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Background, seed.brotherhood, seed.background);
                (bytes memory body, string memory bodyTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Body, seed.brotherhood, seed.body);
                (bytes memory shoes, string memory shoeTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Shoes, seed.brotherhood, seed.shoes);

                parts[0] =
                    ISVGRenderer.Part({name: backgroundTraitName, image: background, palette: _getPalette(background)});
                parts[1] = ISVGRenderer.Part({name: bodyTraitName, image: body, palette: _getPalette(body)});
                parts[2] = ISVGRenderer.Part({name: shoeTraitName, image: shoes, palette: _getPalette(shoes)});
            }

            {
                (bytes memory pants, string memory pantTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Pants, seed.brotherhood, seed.pants);

                (bytes memory shirt, string memory shirtTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Shirt, seed.brotherhood, seed.shirt);

                (bytes memory beard, string memory beardTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Beard, seed.brotherhood, seed.beard);

                parts[3] = ISVGRenderer.Part({name: pantTraitName, image: pants, palette: _getPalette(pants)});
                parts[4] = ISVGRenderer.Part({name: shirtTraitName, image: shirt, palette: _getPalette(shirt)});
                parts[5] = ISVGRenderer.Part({name: beardTraitName, image: beard, palette: _getPalette(beard)});
            }

            {
                (bytes memory hairCapHead, string memory hairCapHeadTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.HairCapHead, seed.brotherhood, seed.hairCapHead);
                (bytes memory eyeAccessory, string memory eyeTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.EyeAccessory, seed.brotherhood, seed.eyeAccessory);
                (bytes memory accessory, string memory accessoryTraitName) =
                    art.getImageByIndex(ISmolJoeArt.TraitType.Accessories, seed.brotherhood, seed.accessory);

                parts[6] = ISVGRenderer.Part({
                    name: hairCapHeadTraitName,
                    image: hairCapHead,
                    palette: _getPalette(hairCapHead)
                });
                parts[7] =
                    ISVGRenderer.Part({name: eyeTraitName, image: eyeAccessory, palette: _getPalette(eyeAccessory)});
                parts[8] =
                    ISVGRenderer.Part({name: accessoryTraitName, image: accessory, palette: _getPalette(accessory)});
            }

            return parts;
        }
    }

    /**
     * @notice Get the color palette pointer for the passed part.
     * @dev The first bytes of the part data are [palette_index, top, right, bottom, left].
     * @param part The part
     */
    function _getPalette(bytes memory part) private view returns (bytes memory) {
        return art.palettes(uint8(part[0]));
    }

    /**
     * @dev Toggle a boolean value which determines if `tokenURI` returns a data URI
     * or an HTTP URL.
     * @param isEnabled Whether the data URI is enabled.
     *
     */
    function _setDataURIEnabled(bool isEnabled) internal {
        if (isDataURIEnabled == isEnabled) {
            revert SmolJoeDescriptor__UpdateToSameState();
        }

        isDataURIEnabled = isEnabled;

        emit DataURIToggled(isEnabled);
    }

    /**
     * @dev Set the SmolJoe's art contract.
     * @param _art the address of the art contract.
     */
    function _setArt(ISmolJoeArt _art) internal {
        if (address(_art) == address(0)) {
            revert SmolJoeDescriptor__InvalidAddress();
        }

        art = _art;

        emit ArtUpdated(_art);
    }

    /**
     * @dev Set the SVG renderer.
     * @param _renderer the address of the renderer contract.
     */
    function _setRenderer(ISVGRenderer _renderer) internal {
        if (address(_renderer) == address(0)) {
            revert SmolJoeDescriptor__InvalidAddress();
        }

        renderer = _renderer;

        emit RendererUpdated(_renderer);
    }
}
