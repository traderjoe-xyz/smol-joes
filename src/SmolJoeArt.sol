// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {Base64} from "base64/base64.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

import {ISmolJoeArt} from "./interfaces/ISmolJoeArt.sol";
import {IInflator} from "./interfaces/IInflator.sol";

/**
 * @title The Smol Joe art storage contract
 * @notice Based on NounsDAO: https://github.com/nounsDAO/nouns-monorepo
 */
contract SmolJoeArt is ISmolJoeArt {
    /**
     * @notice Current Smol Joe Descriptor address
     */
    address public override descriptor;

    /**
     * @notice Current inflator address
     */
    IInflator public override inflator;

    /**
     * @notice Smol Joe Color Palettes (Index => Hex Colors, stored as a contract using SSTORE2)
     */
    mapping(uint8 => address) public override palettesPointers;

    /**
     * @dev Smol Joe Art Traits
     */
    mapping(TraitType => mapping(Brotherhood => Trait)) private _traits;

    /**
     * @notice Brotherhoods House Emblems
     * @dev Emblems have a higher resolution than the other traits
     * That is why they are stored sepparately, directly as a SVG string (in Base64)
     */
    mapping(Brotherhood => address) private _houseEmblemsPointers;

    /**
     * @notice Luminaries trait metadata
     * @dev Luminaries are single images, but have specific traits that do not correspond to real images
     * That is why they are stored sepparately
     */
    mapping(Brotherhood => address) private _luminariesMetadataPointers;

    /**
     * @notice Require that the sender is the descriptor.
     */
    modifier onlyDescriptor() {
        if (msg.sender != descriptor) {
            revert SmolJoeArt__SenderIsNotDescriptor();
        }
        _;
    }

    constructor(address _descriptor, IInflator _inflator) {
        _setDescriptor(_descriptor);
        _setInflator(_inflator);
    }

    /**
     * @notice Get the trait for a given trait type and brotherhood.
     * @param traitType The trait type
     * @param brotherhood The brotherhood
     * @return Trait struct
     */
    function getTrait(TraitType traitType, Brotherhood brotherhood) external view override returns (Trait memory) {
        return _traits[traitType][brotherhood];
    }

    /**
     * @notice Get the image for a given trait type, brotherhood, and index.
     * @param traitType The trait type
     * @param brotherhood The brotherhood
     * @param index The index of the image
     * @return The image bytes and the image name
     */
    function getImageByIndex(TraitType traitType, Brotherhood brotherhood, uint256 index)
        external
        view
        override
        returns (bytes memory, string memory)
    {
        return _imageByIndex(_traits[traitType][brotherhood], index);
    }

    /**
     * @notice Get the Base 64 encoded SVG string describing the emblem for a given brotherhood.
     * @dev This is not a valid SVG as it needs to be appended to the rest of the image built by the SVG renderer
     * @param brotherhood The brotherhood
     * @return The SVG string
     */
    function getHouseEmblem(Brotherhood brotherhood) external view override returns (string memory) {
        address pointer = _houseEmblemsPointers[brotherhood];

        if (pointer == address(0)) {
            return "";
        } else {
            return string(Base64.decode(string(SSTORE2.read(pointer))));
        }
    }

    /**
     * @notice Get the abi encoded array describing the luminaries metadata for a given brotherhood.
     * @param brotherhood The brotherhood
     * @return The metadata string
     */
    function getLuminariesMetadata(Brotherhood brotherhood) external view override returns (bytes[] memory) {
        address pointer = _luminariesMetadataPointers[brotherhood];

        if (pointer == address(0)) {
            return new bytes[](0);
        } else {
            return abi.decode(SSTORE2.read(pointer), (bytes[]));
        }
    }

    /**
     * @notice Get a color palette bytes.
     * @param paletteIndex the identifier of this palette
     * @return The palette bytes
     */
    function palettes(uint8 paletteIndex) external view override returns (bytes memory) {
        address pointer = palettesPointers[paletteIndex];
        if (pointer == address(0)) {
            revert SmolJoeArt__PaletteNotFound();
        }
        return SSTORE2.read(palettesPointers[paletteIndex]);
    }

    /**
     * @notice Set the descriptor address.
     * @dev This function can only be called by the current descriptor.
     * @param _descriptor New descriptor address
     */
    function setDescriptor(address _descriptor) external override onlyDescriptor {
        _setDescriptor(_descriptor);
    }

    /**
     * @notice Set the inflator.
     * @dev This function can only be called by the descriptor.
     */
    function setInflator(IInflator _inflator) external override onlyDescriptor {
        _setInflator(_inflator);
    }

    /**
     * @notice Update a single color palette. This function can be used to
     * add a new color palette or update an existing palette.
     * @dev This function can only be called by the descriptor.
     * @param paletteIndex the identifier of this palette
     * @param palette byte array of colors. every 3 bytes represent an RGB color. max length: 16**4 * 3 = 196_608
     */
    function setPalette(uint8 paletteIndex, bytes calldata palette) external override onlyDescriptor {
        if (palette.length == 0) {
            revert SmolJoeArt__EmptyPalette();
        }

        if (palette.length % 3 != 0 || palette.length > 196_608) {
            revert SmolJoeArt__BadPaletteLength();
        }
        palettesPointers[paletteIndex] = SSTORE2.write(palette);

        emit PaletteSet(paletteIndex);
    }

    /**
     * @notice Update a single color palette address. This function can be used to
     * add a new color palette or update an existing palette. This function does not check for data length validity
     * @dev This function can only be called by the descriptor.
     * @param paletteIndex the identifier of this palette
     * @param pointer the address of the contract holding the palette bytes.
     */
    function setPalettePointer(uint8 paletteIndex, address pointer) external override onlyDescriptor {
        palettesPointers[paletteIndex] = pointer;

        emit PaletteSet(paletteIndex);
    }

    /**
     * @notice Set the house emblem for a given brotherhood.
     * @dev This function can only be called by the descriptor.
     * @param brotherhood The brotherhood
     * @param svgString The Base 64 encoded SVG string
     */
    function setHouseEmblem(Brotherhood brotherhood, string calldata svgString) external override onlyDescriptor {
        address pointer = SSTORE2.write(bytes(svgString));

        _houseEmblemsPointers[brotherhood] = pointer;

        emit HouseEmblemSet(brotherhood, pointer);
    }

    /**
     * @notice Sets the house emblem pointer address.
     * @dev This function can only be called by the descriptor.
     * Can be set to address(0) to remove the house emblem from the image.
     * @param brotherhood The brotherhood
     */
    function setHouseEmblemPointer(Brotherhood brotherhood, address pointer) external override onlyDescriptor {
        _houseEmblemsPointers[brotherhood] = pointer;

        emit HouseEmblemSet(brotherhood, pointer);
    }

    /**
     * @notice Set the luminaries metadata for a given brotherhood.
     * @dev This function can only be called by the descriptor.
     * @param brotherhood The brotherhood
     * @param metadatas The abi encoded metadata array
     */
    function setLuminariesMetadata(Brotherhood brotherhood, bytes calldata metadatas)
        external
        override
        onlyDescriptor
    {
        address pointer = SSTORE2.write(metadatas);

        _luminariesMetadataPointers[brotherhood] = pointer;

        emit LuminariesMetadataSet(brotherhood, pointer);
    }

    /**
     * @notice Sets the luminaries metadata pointer address.
     * @dev This function can only be called by the descriptor.
     * @param brotherhood The brotherhood
     */
    function setLuminariesMetadataPointer(Brotherhood brotherhood, address pointer) external override onlyDescriptor {
        _houseEmblemsPointers[brotherhood] = pointer;

        emit HouseEmblemSet(brotherhood, pointer);
    }

    /**
     * @notice Add a new page of RLE encoded images to a trait.
     * @dev This function can only be called by the descriptor.
     * @param traitType The trait type
     * @param brotherhood The brotherhood
     * @param encodedCompressed The RLE encoded compressed data
     * @param decompressedLength The length of the data once decompressed
     * @param imageCount The number of images in the page
     */
    function addTraits(
        TraitType traitType,
        Brotherhood brotherhood,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyDescriptor {
        _addPage(_traits[traitType][brotherhood], encodedCompressed, decompressedLength, imageCount);
    }

    /**
     * @notice Add a new page of RLE encoded images to a trait. The page has already been deployed to a contract.
     * @dev This function can only be called by the descriptor.
     * @param traitType The trait type
     * @param brotherhood The brotherhood
     * @param pointer The address of the contract holding the RLE encoded compressed data
     * @param decompressedLength The length of the data once decompressed
     * @param imageCount The number of images in the page
     */
    function addTraitsFromPointer(
        TraitType traitType,
        Brotherhood brotherhood,
        address pointer,
        uint80 decompressedLength,
        uint16 imageCount
    ) external override onlyDescriptor {
        _addPage(_traits[traitType][brotherhood], pointer, decompressedLength, imageCount);
    }

    /**
     * @dev Add a new page of RLE encoded images to a trait by deploying a new contract to hold the data.
     * @param trait The trait to add the page to
     * @param encodedCompressed The RLE encoded compressed data
     * @param decompressedLength The length of the data once decompressed
     * @param imageCount The number of images in the page
     */
    function _addPage(
        Trait storage trait,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) internal {
        if (encodedCompressed.length == 0) {
            revert SmolJoeArt__EmptyBytes();
        }
        address pointer = SSTORE2.write(encodedCompressed);
        _addPage(trait, pointer, decompressedLength, imageCount);
    }

    /**
     * @dev Add a new page of RLE encoded images to a trait by using an existing contract to hold the data.
     * @param trait The trait to add the page to
     * @param pointer The address of the contract holding the RLE encoded compressed data
     * @param decompressedLength The length of the data once decompressed
     * @param imageCount The number of images in the page
     */
    function _addPage(Trait storage trait, address pointer, uint80 decompressedLength, uint16 imageCount) internal {
        if (decompressedLength == 0) {
            revert SmolJoeArt__BadDecompressedLength();
        }
        if (imageCount == 0) {
            revert SmolJoeArt__BadImageCount();
        }
        trait.storagePages.push(
            SmolJoeArtStoragePage({pointer: pointer, decompressedLength: decompressedLength, imageCount: imageCount})
        );
        trait.storedImagesCount += imageCount;
    }

    /**
     * @dev Given an image index, this function finds the storage page the image is in, and the relative index
     * inside the page, so the image can be read from storage.
     * Example: if you have 2 pages with 100 images each, and you want to get image 150, this function would return
     * the 2nd page, and the 50th index.
     * @param trait The trait to get the image from
     * @param index The index of the image
     * @return The decompressed image bytes and the image name
     */
    function _imageByIndex(ISmolJoeArt.Trait storage trait, uint256 index)
        internal
        view
        returns (bytes memory, string memory)
    {
        (ISmolJoeArt.SmolJoeArtStoragePage storage page, uint256 indexInPage) = _getPage(trait.storagePages, index);
        (bytes[] memory decompressedImages, string[] memory imagesNames) = _decompressAndDecode(page);

        return (decompressedImages[indexInPage], imagesNames[indexInPage]);
    }

    /**
     * @dev Given an image index, this function finds the storage page the image is in, and the relative index
     * inside the page, so the image can be read from storage.
     * Example: if you have 2 pages with 100 images each, and you want to get image 150, this function would return
     * the 2nd page, and the 50th index.
     * @param pages The pages to get the image from
     * @param index The index of the image
     * @return The storage page and the relative index inside the page
     */
    function _getPage(ISmolJoeArt.SmolJoeArtStoragePage[] storage pages, uint256 index)
        internal
        view
        returns (ISmolJoeArt.SmolJoeArtStoragePage storage, uint256)
    {
        uint256 len = pages.length;
        uint256 pageFirstImageIndex = 0;
        for (uint256 i = 0; i < len; i++) {
            ISmolJoeArt.SmolJoeArtStoragePage storage page = pages[i];

            uint256 pageImageCount = page.imageCount;

            if (index < pageFirstImageIndex + pageImageCount) {
                return (page, index - pageFirstImageIndex);
            }

            pageFirstImageIndex += pageImageCount;
        }

        revert SmolJoeArt__ImageNotFound();
    }

    /**
     * @dev Decompress and decode the data in a storage page.
     * @param page The storage page
     * @return The decompressed images and the images names
     */
    function _decompressAndDecode(ISmolJoeArt.SmolJoeArtStoragePage storage page)
        internal
        view
        returns (bytes[] memory, string[] memory)
    {
        bytes memory compressedData = SSTORE2.read(page.pointer);
        (IInflator.ErrorCode err, bytes memory decompressedData) =
            inflator.puff(compressedData, page.decompressedLength);

        if (err != IInflator.ErrorCode.ERR_NONE) {
            revert SmolJoeArt__DecompressionError(uint8(err));
        }

        return abi.decode(decompressedData, (bytes[], string[]));
    }

    /**
     * @dev Set the descriptor address.
     * @param _descriptor New descriptor address
     */
    function _setDescriptor(address _descriptor) internal {
        if (_descriptor == address(0)) {
            revert SmolJoeArt__InvalidAddress();
        }

        descriptor = _descriptor;

        emit DescriptorUpdated(descriptor);
    }

    /**
     * @dev Set the inflator address.
     * @param _inflator New inflator address
     */
    function _setInflator(IInflator _inflator) internal {
        if (address(_inflator) == address(0)) {
            revert SmolJoeArt__InvalidAddress();
        }

        inflator = _inflator;

        emit InflatorUpdated(address(_inflator));
    }
}
