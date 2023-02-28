// SPDX-License-Identifier: GPL-3.0

/// @title The Smol Joe art storage contract
/// Inspired by Nouns DAO's NounsArt contract

pragma solidity ^0.8.6;

import {ISmolJoeArt} from "./interfaces/ISmolJoeArt.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {IInflator} from "./interfaces/IInflator.sol";

contract SmolJoeArt is ISmolJoeArt {
    /// @notice Current Smol Joe Descriptor address
    address public override descriptor;

    /// @notice Current inflator address
    IInflator public override inflator;

    /// @notice Smol Joe Color Palettes (Index => Hex Colors, stored as a contract using SSTORE2)
    mapping(uint8 => address) public palettesPointers;

    Trait public backgroundsTrait;

    /// @notice Smol Joe Bodies Trait
    Trait public bodiesTrait;

    Trait public pantsTrait;

    Trait public shoesTrait;

    Trait public shirtsTrait;

    Trait public beardsTrait;

    /// @notice Smol Joe Heads Trait
    Trait public headsTrait;

    Trait public eyesTraits;

    Trait public accessoriesTraits;

    bytes constant emptyItem = "\x00\x00\x00\x00\x00";

    /**
     * @notice Require that the sender is the descriptor.
     */
    modifier onlyDescriptor() {
        if (msg.sender != descriptor) {
            revert SenderIsNotDescriptor();
        }
        _;
    }

    constructor(address _descriptor, IInflator _inflator) {
        descriptor = _descriptor;
        inflator = _inflator;
    }

    /**
     * @notice Set the descriptor.
     * @dev This function can only be called by the current descriptor.
     */
    function setDescriptor(address _descriptor) external override onlyDescriptor {
        address oldDescriptor = descriptor;
        descriptor = _descriptor;

        emit DescriptorUpdated(oldDescriptor, descriptor);
    }

    /**
     * @notice Set the inflator.
     * @dev This function can only be called by the descriptor.
     */
    function setInflator(IInflator _inflator) external override onlyDescriptor {
        address oldInflator = address(inflator);
        inflator = _inflator;

        emit InflatorUpdated(oldInflator, address(_inflator));
    }

    function getBackgroundsTrait() external view override returns (Trait memory) {
        return backgroundsTrait;
    }

    /**
     * @notice Get the Trait struct for bodies.
     * @dev This explicit getter is needed because implicit getters for structs aren't fully supported yet:
     * https://github.com/ethereum/solidity/issues/11826
     * @return Trait the struct, including a total image count, and an array of storage pages.
     */
    function getBodiesTrait() external view override returns (Trait memory) {
        return bodiesTrait;
    }

    function getPantsTrait() external view override returns (Trait memory) {
        return pantsTrait;
    }

    function getShoesTrait() external view override returns (Trait memory) {
        return shoesTrait;
    }

    function getShirtsTrait() external view override returns (Trait memory) {
        return shirtsTrait;
    }

    function getBeardsTrait() external view override returns (Trait memory) {
        return beardsTrait;
    }

    /**
     * @notice Get the Trait struct for heads.
     * @dev This explicit getter is needed because implicit getters for structs aren't fully supported yet:
     * https://github.com/ethereum/solidity/issues/11826
     * @return Trait the struct, including a total image count, and an array of storage pages.
     */
    function getHeadsTrait() external view override returns (Trait memory) {
        return headsTrait;
    }

    function getEyesTrait() external view override returns (Trait memory) {
        return eyesTraits;
    }

    function getAccessoriesTrait() external view override returns (Trait memory) {
        return accessoriesTraits;
    }

    /**
     * @notice Update a single color palette. This function can be used to
     * add a new color palette or update an existing palette.
     * @param paletteIndex the identifier of this palette
     * @param palette byte array of colors. every 3 bytes represent an RGB color. max length: 256 * 3 = 768
     * @dev This function can only be called by the descriptor.
     */
    function setPalette(uint8 paletteIndex, bytes calldata palette) external override onlyDescriptor {
        if (palette.length == 0) {
            revert EmptyPalette();
        }
        if (palette.length % 3 != 0 || palette.length > 768) {
            revert BadPaletteLength();
        }
        palettesPointers[paletteIndex] = SSTORE2.write(palette);

        emit PaletteSet(paletteIndex);
    }

    /**
     * @notice Add a batch of background images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the descriptor.
     */
    function addBackgrounds(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(backgroundsTrait, encodedCompressed, decompressedLength, imageCount);

        emit BackgroundsAdded(imageCount);
    }

    /**
     * @notice Add a batch of body images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the descriptor.
     */
    function addBodies(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(bodiesTrait, encodedCompressed, decompressedLength, imageCount);

        emit BodiesAdded(imageCount);
    }

    function addPants(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(pantsTrait, encodedCompressed, decompressedLength, imageCount);

        // emit PantsAdded(imageCount);
    }

    function addShoes(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(shoesTrait, encodedCompressed, decompressedLength, imageCount);

        // emit ShoesAdded(imageCount);
    }

    function addShirts(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(shirtsTrait, encodedCompressed, decompressedLength, imageCount);

        // emit ShirtsAdded(imageCount);
    }

    function addBeards(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(beardsTrait, encodedCompressed, decompressedLength, imageCount);

        // emit BeardsAdded(imageCount);
    }

    /**
     * @notice Add a batch of head images.
     * @param encodedCompressed bytes created by taking a string array of RLE-encoded images, abi encoding it as a bytes array,
     * and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the descriptor.
     */
    function addHeads(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(headsTrait, encodedCompressed, decompressedLength, imageCount);

        emit HeadsAdded(imageCount);
    }

    function addEyes(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(eyesTraits, encodedCompressed, decompressedLength, imageCount);

        // emit EyesAdded(imageCount);
    }

    function addAccessories(bytes calldata encodedCompressed, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        _addPage(accessoriesTraits, encodedCompressed, decompressedLength, imageCount);

        // emit AccessoriesAdded(imageCount);
    }

    /**
     * @notice Update a single color palette. This function can be used to
     * add a new color palette or update an existing palette. This function does not check for data length validity
     * (len <= 768, len % 3 == 0).
     * @param paletteIndex the identifier of this palette
     * @param pointer the address of the contract holding the palette bytes. every 3 bytes represent an RGB color.
     * max length: 256 * 3 = 768.
     * @dev This function can only be called by the descriptor.
     */
    function setPalettePointer(uint8 paletteIndex, address pointer) external override onlyDescriptor {
        palettesPointers[paletteIndex] = pointer;

        emit PaletteSet(paletteIndex);
    }

    /**
     * @notice Add a batch of background images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the descriptor.
     */
    function addBackgroundsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(backgroundsTrait, pointer, decompressedLength, imageCount);

        emit BackgroundsAdded(imageCount);
    }

    /**
     * @notice Add a batch of body images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches.
     * @dev This function can only be called by the descriptor.
     */
    function addBodiesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(bodiesTrait, pointer, decompressedLength, imageCount);

        emit BodiesAdded(imageCount);
    }

    function addPantsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(pantsTrait, pointer, decompressedLength, imageCount);

        // emit PantsAdded(imageCount);
    }

    function addShoesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(shoesTrait, pointer, decompressedLength, imageCount);

        // emit ShoesAdded(imageCount);
    }

    function addShirtsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(shirtsTrait, pointer, decompressedLength, imageCount);

        // emit ShirtsAdded(imageCount);
    }

    function addBeardsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(beardsTrait, pointer, decompressedLength, imageCount);

        // emit BeardsAdded(imageCount);
    }

    /**
     * @notice Add a batch of head images from an existing storage contract.
     * @param pointer the address of a contract where the image batch was stored using SSTORE2. The data
     * format is expected to be like {encodedCompressed}: bytes created by taking a string array of
     * RLE-encoded images, abi encoding it as a bytes array, and finally compressing it using deflate.
     * @param decompressedLength the size in bytes the images bytes were prior to compression; required input for Inflate.
     * @param imageCount the number of images in this batch; used when searching for images among batches
     * @dev This function can only be called by the descriptor..
     */
    function addHeadsFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(headsTrait, pointer, decompressedLength, imageCount);

        emit HeadsAdded(imageCount);
    }

    function addEyesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(eyesTraits, pointer, decompressedLength, imageCount);

        // emit EyesAdded(imageCount);
    }

    function addAccessoriesFromPointer(address pointer, uint80 decompressedLength, uint16 imageCount)
        external
        override
        onlyDescriptor
    {
        addPage(accessoriesTraits, pointer, decompressedLength, imageCount);

        // emit AccessoriesAdded(imageCount);
    }

    /**
     * @notice Get a background image bytes (RLE-encoded).
     */
    function backgrounds(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(backgroundsTrait, index);
    }

    /**
     * @notice Get a body image bytes (RLE-encoded).
     */
    function bodies(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(bodiesTrait, index);
    }

    /**
     * @notice Get a pants image bytes (RLE-encoded).
     */
    function pants(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(pantsTrait, index);
    }

    /**
     * @notice Get a shoes image bytes (RLE-encoded).
     */
    function shoes(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(shoesTrait, index);
    }

    /**
     * @notice Get a shirt image bytes (RLE-encoded).
     */
    function shirts(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(shirtsTrait, index);
    }

    /**
     * @notice Get a beard image bytes (RLE-encoded).
     */
    function beards(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(beardsTrait, index);
    }

    /**
     * @notice Get a head image bytes (RLE-encoded).
     */
    function heads(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(headsTrait, index);
    }

    /**
     * @notice Get a eyes image bytes (RLE-encoded).
     */

    function eyes(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(eyesTraits, index);
    }

    /**
     * @notice Get a accessories image bytes (RLE-encoded).
     */

    function accessories(uint256 index) public view override returns (bytes memory) {
        return imageByIndex(accessoriesTraits, index);
    }

    /**
     * @notice Get a color palette bytes.
     */
    function palettes(uint8 paletteIndex) public view override returns (bytes memory) {
        address pointer = palettesPointers[paletteIndex];
        if (pointer == address(0)) {
            revert PaletteNotFound();
        }
        return SSTORE2.read(palettesPointers[paletteIndex]);
    }

    function _addPage(
        Trait storage trait,
        bytes calldata encodedCompressed,
        uint80 decompressedLength,
        uint16 imageCount
    ) internal {
        if (encodedCompressed.length == 0) {
            revert EmptyBytes();
        }
        address pointer = SSTORE2.write(encodedCompressed);
        addPage(trait, pointer, decompressedLength, imageCount);
    }

    function addPage(Trait storage trait, address pointer, uint80 decompressedLength, uint16 imageCount) internal {
        if (decompressedLength == 0) {
            revert BadDecompressedLength();
        }
        if (imageCount == 0) {
            revert BadImageCount();
        }
        trait.storagePages.push(
            SmolJoeArtStoragePage({pointer: pointer, decompressedLength: decompressedLength, imageCount: imageCount})
        );
        trait.storedImagesCount += imageCount;
    }

    function imageByIndex(ISmolJoeArt.Trait storage trait, uint256 index) internal view returns (bytes memory) {
        (ISmolJoeArt.SmolJoeArtStoragePage storage page, uint256 indexInPage) = getPage(trait.storagePages, index);
        bytes[] memory decompressedImages = decompressAndDecode(page);
        return decompressedImages[indexInPage];
    }

    /**
     * @dev Given an image index, this function finds the storage page the image is in, and the relative index
     * inside the page, so the image can be read from storage.
     * Example: if you have 2 pages with 100 images each, and you want to get image 150, this function would return
     * the 2nd page, and the 50th index.
     * @return ISmolJoeArt.SmolJoeArtStoragePage the page containing the image at index
     * @return uint256 the index of the image in the page
     */
    function getPage(ISmolJoeArt.SmolJoeArtStoragePage[] storage pages, uint256 index)
        internal
        view
        returns (ISmolJoeArt.SmolJoeArtStoragePage storage, uint256)
    {
        uint256 len = pages.length;
        uint256 pageFirstImageIndex = 0;
        for (uint256 i = 0; i < len; i++) {
            ISmolJoeArt.SmolJoeArtStoragePage storage page = pages[i];

            if (index < pageFirstImageIndex + page.imageCount) {
                return (page, index - pageFirstImageIndex);
            }

            pageFirstImageIndex += page.imageCount;
        }

        revert ImageNotFound();
    }

    function decompressAndDecode(ISmolJoeArt.SmolJoeArtStoragePage storage page)
        internal
        view
        returns (bytes[] memory)
    {
        bytes memory compressedData = SSTORE2.read(page.pointer);
        (, bytes memory decompressedData) = inflator.puff(compressedData, page.decompressedLength);
        return abi.decode(decompressedData, (bytes[]));
    }
}
