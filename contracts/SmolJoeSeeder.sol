// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal, ISmolJoeArt} from "./interfaces/ISmolJoeDescriptorMinimal.sol";

/**
 * @title The SmolJoes pseudo-random seed generator
 * @notice Based on NounsDAO: https://github.com/nounsDAO/nouns-monorepo
 */
contract SmolJoeSeeder is Ownable2Step, ISmolJoeSeeder {
    uint256 private constant MASK_UINT8 = 0xff;
    uint256 private constant UINT8_IN_UINT256 = 32;
    uint256 private constant RANDOM_SEED_SHIFT = 16;

    // forgefmt: disable-next-item
    uint8[] private _luminariesAvailable = 
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37,
        38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55,
        56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73,
        74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91,
        92, 93, 94, 95, 96, 97, 98, 99];

    uint256[4] private _originalsArt;

    uint256 private _randomnessNonce;

    address public override smolJoes;

    /**
     * @notice Get the art mapping for the original Smol Joes
     * @param tokenId The token ID of the Smol Joe
     * @return The art index corresponding to the token ID
     */
    function getOriginalsArtMapping(uint256 tokenId) external view override returns (uint8) {
        return _getOriginalsArtMapping(tokenId);
    }

    /**
     * @notice Updates the mapping connecting the Originals to their corresponding art
     * @param artMapping The new art mapping
     */
    function updateOriginalsArtMapping(uint8[100] calldata artMapping) external override onlyOwner {
        uint256 packedMapping;
        for (uint256 i = 0; i < artMapping.length; i++) {
            packedMapping += uint256(artMapping[i]) << (i % UINT8_IN_UINT256) * 8;

            if ((i + 1) % UINT8_IN_UINT256 == 0) {
                _originalsArt[i / UINT8_IN_UINT256] = packedMapping;
                packedMapping = 0;
            }
        }

        _originalsArt[3] = packedMapping;

        emit OriginalsArtMappingUpdated(artMapping);
    }

    /**
     * @notice Updates the address of the Smol Joes contract
     * @param _smolJoes The new address of the Smol Joes contract
     */
    function setSmolJoesAddress(address _smolJoes) external override onlyOwner {
        if (_smolJoes == address(0) || _smolJoes == smolJoes) {
            revert SmolJoeSeeder__InvalidAddress();
        }

        smolJoes = _smolJoes;

        emit SmolJoesAddressSet(_smolJoes);
    }

    /**
     * @notice Generate a pseudo-random Smol Joe seed.
     * @param tokenId The token ID of the Smol Joe
     * @param descriptor The Smol Joe descriptor
     * @return The seed for the Smol Joe
     */
    function generateSeed(uint256 tokenId, ISmolJoeDescriptorMinimal descriptor)
        external
        override
        returns (Seed memory)
    {
        if (msg.sender != smolJoes) {
            revert SmolJoeSeeder__OnlySmolJoes();
        }

        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, tokenId, _randomnessNonce++))
        );

        // Need to store the seed into memory to prevent stack too deep errors
        Seed memory seed;

        if (tokenId < 100) {
            seed.originalId = _getOriginalsArtMapping(tokenId) + 1;
        } else if (tokenId < 200) {
            uint256 luminariesAvailableLength = _luminariesAvailable.length;

            uint256 randomIndex = randomNumber % luminariesAvailableLength;
            uint256 randomLuminary = _luminariesAvailable[randomIndex];

            seed.luminaryId = uint8(randomLuminary % 10 + 1);
            // Pick the corresponding brotherhood (1-10)
            seed.brotherhood = ISmolJoeArt.Brotherhood(randomLuminary / 10 + 1);

            // Remove the luminary from the available list
            _luminariesAvailable[randomIndex] = _luminariesAvailable[luminariesAvailableLength - 1];
            _luminariesAvailable.pop();
        } else {
            // Get the brotherhood first
            ISmolJoeArt.Brotherhood brotherhood = ISmolJoeArt.Brotherhood(uint8(randomNumber % 10 + 1));
            seed.brotherhood = brotherhood;
            randomNumber >>= 4;

            // Get the background. This is the only trait that is not brotherhood specific
            uint256 backgroundCount =
                descriptor.traitCount(ISmolJoeArt.TraitType.Background, ISmolJoeArt.Brotherhood.None);
            seed.background = uint16(randomNumber % backgroundCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            // Get the rest of the traits
            uint256 bodyCount = descriptor.traitCount(ISmolJoeArt.TraitType.Body, ISmolJoeArt.Brotherhood.None);
            seed.body = uint16(randomNumber % bodyCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            uint256 pantCount = descriptor.traitCount(ISmolJoeArt.TraitType.Pants, ISmolJoeArt.Brotherhood.None);
            seed.pants = uint16(randomNumber % pantCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            uint256 shoeCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shoes, ISmolJoeArt.Brotherhood.None);
            seed.shoes = uint16(randomNumber % shoeCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            uint256 shirtCount = descriptor.traitCount(ISmolJoeArt.TraitType.Shirt, ISmolJoeArt.Brotherhood.None);
            seed.shirt = uint16(randomNumber % shirtCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            uint256 beardCount = descriptor.traitCount(ISmolJoeArt.TraitType.Beard, ISmolJoeArt.Brotherhood.None);
            seed.beard = uint16(randomNumber % beardCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            uint256 headCount = descriptor.traitCount(ISmolJoeArt.TraitType.HairCapHead, ISmolJoeArt.Brotherhood.None);
            seed.hairCapHead = uint16(randomNumber % headCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            uint256 eyeCount = descriptor.traitCount(ISmolJoeArt.TraitType.EyeAccessory, ISmolJoeArt.Brotherhood.None);
            seed.eyeAccessory = uint16(randomNumber % eyeCount);
            randomNumber >>= RANDOM_SEED_SHIFT;

            uint256 accessoryCount =
                descriptor.traitCount(ISmolJoeArt.TraitType.Accessories, ISmolJoeArt.Brotherhood.None);
            seed.accessory = uint16(randomNumber % accessoryCount);
        }

        return seed;
    }

    /**
     * @notice Get the art mapping for the original Smol Joes
     * @param tokenId The token ID of the Smol Joe
     * @return The art index corresponding to the token ID
     */
    function _getOriginalsArtMapping(uint256 tokenId) internal view returns (uint8) {
        return uint8((_originalsArt[tokenId / UINT8_IN_UINT256] >> (tokenId % UINT8_IN_UINT256) * 8) & MASK_UINT8);
    }
}
