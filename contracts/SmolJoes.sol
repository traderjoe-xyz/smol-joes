// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {
    OZNFTBaseUpgradeable, IOZNFTBaseUpgradeable
} from "@traderjoe-xyz/nft-base-contracts/src/OZNFTBaseUpgradeable.sol";

import {ISmolJoeDescriptorMinimal} from "./interfaces/ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoes} from "./interfaces/ISmolJoes.sol";

/**
 * @title The Smol Joe ERC-721 token
 */
contract SmolJoes is OZNFTBaseUpgradeable, ISmolJoes {
    // The Smol Joe token URI descriptor
    ISmolJoeDescriptorMinimal public descriptor;

    // The Smol Joe token seeder
    ISmolJoeSeeder public seeder;

    // The smol joe seeds
    mapping(uint256 => ISmolJoeSeeder.Seed) public seeds;

    constructor(ISmolJoeDescriptorMinimal _descriptor, ISmolJoeSeeder _seeder) initializer {
        descriptor = _descriptor;
        seeder = _seeder;

        __OZNFTBase_init("On-chain Thing", "SJT", address(1), 0, address(1), address(1));
    }

    function mint(address to, uint256 tokenID) public {
        seeds[tokenID] = seeder.generateSeed(tokenID, descriptor);
        _mint(to, tokenID);
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "SmolJoes: URI query for nonexistent token");
        return descriptor.tokenURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     */
    function dataURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "SmolJoes: URI query for nonexistent token");
        return descriptor.dataURI(tokenId, seeds[tokenId]);
    }

    /**
     * @notice Set the token URI descriptor.
     * @dev Only callable by the owner when not locked.
     */
    function setDescriptor(ISmolJoeDescriptorMinimal _descriptor) external onlyOwner {
        descriptor = _descriptor;

        emit DescriptorUpdated(_descriptor);
    }

    /**
     * @notice Set the token seeder.
     * @dev Only callable by the owner when not locked.
     */
    function setSeeder(ISmolJoeSeeder _seeder) external onlyOwner {
        seeder = _seeder;

        emit SeederUpdated(_seeder);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IOZNFTBaseUpgradeable, OZNFTBaseUpgradeable)
        returns (bool)
    {
        return interfaceId == type(ISmolJoes).interfaceId || OZNFTBaseUpgradeable.supportsInterface(interfaceId);
    }
}
