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

    // The Smol Joe Workshop, which can mint tokens
    address public workshop;

    // The smol joe seeds
    mapping(uint256 => ISmolJoeSeeder.Seed) public seeds;

    constructor(ISmolJoeDescriptorMinimal _descriptor, ISmolJoeSeeder _seeder) initializer {
        descriptor = _descriptor;
        seeder = _seeder;

        // @todo Use LZ endpoint and bridge token seed
        __OZNFTBase_init("On-chain Thing", "SJT", address(1), 0, address(1), address(1));
    }

    /**
     * @notice Mint a new token.
     * @dev The mint logic is expected to be handled by the Smol Joe Workshop.
     * The Workshop needs to correctly account for the available token IDs and mint accordingly.
     * The Workshop address can be updated by the owner, allowing the implementation of different sale mechanisms in the future.
     * @param to The address to mint the token to.
     * @param tokenID The token ID to mint.
     */
    function mint(address to, uint256 tokenID) external override {
        if (msg.sender != address(workshop)) {
            revert SmolJoes__Unauthorized();
        }

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
     * @param _descriptor The new descriptor address.
     */
    function setDescriptor(ISmolJoeDescriptorMinimal _descriptor) external onlyOwner {
        descriptor = _descriptor;

        emit DescriptorUpdated(address(_descriptor));
    }

    /**
     * @notice Set the token seeder.
     * @param _seeder The new seeder address.
     */
    function setSeeder(ISmolJoeSeeder _seeder) external onlyOwner {
        seeder = _seeder;

        emit SeederUpdated(address(_seeder));
    }

    /**
     * @notice Set the token workshop.
     * @param _workshop The new workshop address.
     */
    function setWorkshop(address _workshop) external onlyOwner {
        workshop = _workshop;

        emit WorkshopUpdated(_workshop);
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
