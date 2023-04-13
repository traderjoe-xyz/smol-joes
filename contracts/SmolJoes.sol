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
    /**
     * @notice The Smol Joe token URI descriptor.
     */
    ISmolJoeDescriptorMinimal public override descriptor;

    /**
     * @notice The Smol Joe token seeder.
     * @dev During mint, the seeder will generate a seed for the token.
     * The seed will be used to build the token URI.
     */
    ISmolJoeSeeder public override seeder;

    /**
     * @notice The Smol Joe Workshop, responsible of the token minting.
     * @dev Different sale mechanisms can be implemented in the workshop.
     */
    address public override workshop;

    /**
     * @notice The smol joe seeds
     * @dev Seeds are set by the Smol Joe Seeder during minting.
     * They are used to generate the token URI.
     */
    mapping(uint256 => ISmolJoeSeeder.Seed) private _seeds;

    constructor(ISmolJoeDescriptorMinimal _descriptor, ISmolJoeSeeder _seeder) initializer {
        // @todo Use LZ endpoint and bridge token seed
        __OZNFTBase_init("On-chain Thing", "SJT", address(1), 0, address(1), address(1));

        _setDescriptor(_descriptor);
        _setSeeder(_seeder);
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @param tokenId The token ID to get the URI for.
     * @return The URI for the given token ID.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            revert SmolJoes__InexistentToken(tokenId);
        }

        return descriptor.tokenURI(tokenId, _seeds[tokenId]);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     * @param tokenId The token ID to get the data URI for.
     * @return The data URI for the given token ID.
     */
    function dataURI(uint256 tokenId) public view returns (string memory) {
        if (!_exists(tokenId)) {
            revert SmolJoes__InexistentToken(tokenId);
        }

        return descriptor.dataURI(tokenId, _seeds[tokenId]);
    }

    /**
     * @notice Get the seed for a given token ID.
     * @dev The seed is set by the Smol Joe Seeder during minting.
     * It is used to generate the token URI.
     * @param tokenId The token ID to get the seed for.
     * @return The seed for the given token ID.
     */
    function getTokenSeed(uint256 tokenId) external view override returns (ISmolJoeSeeder.Seed memory) {
        if (!_exists(tokenId)) {
            revert SmolJoes__InexistentToken(tokenId);
        }

        return _seeds[tokenId];
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

        _seeds[tokenID] = seeder.generateSeed(tokenID, descriptor);
        _mint(to, tokenID);
    }

    /**
     * @notice Set the token URI descriptor.
     * @param _descriptor The new descriptor address.
     */
    function setDescriptor(ISmolJoeDescriptorMinimal _descriptor) external onlyOwner {
        _setDescriptor(_descriptor);
    }

    /**
     * @notice Set the token seeder.
     * @param _seeder The new seeder address.
     */
    function setSeeder(ISmolJoeSeeder _seeder) external onlyOwner {
        _setSeeder(_seeder);
    }

    /**
     * @notice Set the token workshop.
     * @dev Workshop address can be set to zero to prevent further minting (until upgraded again).
     * @param _workshop The new workshop address.
     */
    function setWorkshop(address _workshop) external onlyOwner {
        _setWorkshop(_workshop);
    }

    /**
     * @notice Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these IDs are created.
     * This function call must use less than 30 000 gas.
     * @param interfaceId InterfaceId to consider. Comes from type(InterfaceContract).interfaceId
     * @return True if the considered interface is supported
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IOZNFTBaseUpgradeable, OZNFTBaseUpgradeable)
        returns (bool)
    {
        return interfaceId == type(ISmolJoes).interfaceId || OZNFTBaseUpgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Set the token URI descriptor.
     * @param _descriptor The new descriptor address.
     */
    function _setDescriptor(ISmolJoeDescriptorMinimal _descriptor) internal {
        if (address(_descriptor) == address(0)) {
            revert SmolJoes__InvalidAddress();
        }

        descriptor = _descriptor;

        emit DescriptorUpdated(address(_descriptor));
    }

    /**
     * @notice Set the token seeder.
     * @param _seeder The new seeder address.
     */
    function _setSeeder(ISmolJoeSeeder _seeder) internal {
        if (address(_seeder) == address(0)) {
            revert SmolJoes__InvalidAddress();
        }

        seeder = _seeder;

        emit SeederUpdated(address(_seeder));
    }

    /**
     * @notice Set the token workshop.
     * @dev Workshop address can be set to zero to prevent further minting (until upgraded again).
     * @param _workshop The new workshop address.
     */
    function _setWorkshop(address _workshop) internal {
        workshop = _workshop;

        emit WorkshopUpdated(_workshop);
    }
}
