// SPDX-License-Identifier: GPL-3.0

/// @title The Smol Joe ERC-721 token

pragma solidity ^0.8.6;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ISmolJoeDescriptorMinimal} from "./interfaces/ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoes} from "./interfaces/ISmolJoes.sol";
import {ERC721} from "openzeppelin/token/ERC721/ERC721.sol";

contract SmolJoes is ISmolJoes, Ownable, ERC721 {
    // The Smol Joe token URI descriptor
    ISmolJoeDescriptorMinimal public descriptor;

    // The Smol Joe token seeder
    ISmolJoeSeeder public seeder;

    // The smol joe seeds
    mapping(uint256 => ISmolJoeSeeder.Seed) public seeds;

    constructor(ISmolJoeDescriptorMinimal _descriptor, ISmolJoeSeeder _seeder) ERC721("Smol Joe", "SJ") {
        descriptor = _descriptor;
        seeder = _seeder;
    }

    function mint(uint256 tokenID) public {
        seeds[tokenID] = seeder.generateSeed(tokenID, descriptor);
        _mint(msg.sender, tokenID);
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
}
