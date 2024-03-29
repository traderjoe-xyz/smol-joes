// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {Pausable} from "openzeppelin/security/Pausable.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {IERC721Metadata} from "openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";

import {ISmolJoes} from "./interfaces/ISmolJoes.sol";
import {ISmolJoeWorkshop} from "./interfaces/ISmolJoeWorkshop.sol";
import {IOGMigrationWorkshop} from "./interfaces/IOGMigrationWorkshop.sol";

/**
 * @title The Originals Workshop is used to migrate OG Smol Joes into their own contract.
 */
contract OGMigrationWorkshop is Ownable2Step, Pausable, ReentrancyGuard, IOGMigrationWorkshop {
    /**
     * @dev Address where the burned tokens are sent
     */
    address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /**
     * @dev Originals are tokens 0 to 99 in the Smol Joes V2 collection
     */
    uint256 private constant ORIGINALS_LAST_TOKEN_ID = 99;

    /**
     * @notice The Smol Joes Season 2 contract address
     */
    ISmolJoes public immutable override smolJoesV2;

    /**
     * @notice The new Originals contract address
     */
    ISmolJoes public immutable override originals;

    /**
     * @notice The start time of the migration
     */
    uint256 public override startTime;

    /**
     * @dev Contract constructor
     * @param _smolJoesV2 Address of the Smol Joes V2 collection
     * @param _originals Address of the Originals collection
     * @param _startTime The start time of the migration
     */
    constructor(address _smolJoesV2, address _originals, uint256 _startTime) {
        if (keccak256(bytes(IERC721Metadata(_smolJoesV2).name())) != keccak256("Smol Joes Season 2")) {
            revert OGMigrationWorkshop__InvalidCollectionAddress(_smolJoesV2);
        }

        if (keccak256(bytes(IERC721Metadata(_originals).name())) != keccak256("OG Smol Joes")) {
            revert OGMigrationWorkshop__InvalidCollectionAddress(_originals);
        }

        smolJoesV2 = ISmolJoes(_smolJoesV2);
        originals = ISmolJoes(_originals);
        startTime = _startTime;
    }

    /**
     * @notice Pauses the contract to prevent any upgrades
     */
    function pause() external override onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses the contract, allowing upgrades again
     */
    function unpause() external override onlyOwner {
        _unpause();
    }

    /**
     * @notice Sets the start time of the migration
     * @param _startTime The start time of the migration
     */
    function setStartTime(uint256 _startTime) external override onlyOwner {
        if (_startTime < block.timestamp) {
            revert OGMigrationWorkshop__InvalidStartTime();
        }

        startTime = _startTime;

        emit StartTimeSet(_startTime);
    }

    /**
     * @notice Migrates a Smol Joe V2 token into the Originals contract
     * @param tokenID The token ID to migrate
     */
    function migrate(uint256 tokenID) external override whenNotPaused nonReentrant {
        if (tokenID > ORIGINALS_LAST_TOKEN_ID) {
            revert OGMigrationWorkshop__InvalidTokenID();
        }

        if (block.timestamp < startTime) {
            revert OGMigrationWorkshop__MigrationNotStarted();
        }

        _verifyOwnership(tokenID);
        _burn(tokenID);
        _mint(msg.sender, tokenID);

        emit Migration(tokenID);
    }

    /**
     * @dev Verify that the caller owns the token that is meant to be burnt
     * @param tokenId The token ID to check ownership for
     */
    function _verifyOwnership(uint256 tokenId) internal view {
        if (smolJoesV2.ownerOf(tokenId) != msg.sender) {
            revert OGMigrationWorkshop__TokenOwnershipRequired();
        }
    }

    /**
     * @dev Mints an Original
     * The Workshop contract needs to be allowed to mint tokens on behalf of the Originals contract
     * @param to The address to mint the token to
     * @param tokenId The token ID to mint
     */
    function _mint(address to, uint256 tokenId) internal {
        originals.mint(to, tokenId);
    }

    /**
     * @dev Burns a smol joe V2 by sending it to `address(dead)`
     * @param tokenId The token ID to burn
     */
    function _burn(uint256 tokenId) internal {
        smolJoesV2.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
    }
}
