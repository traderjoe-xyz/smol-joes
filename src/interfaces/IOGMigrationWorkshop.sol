// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";

import {ISmolJoes} from "./ISmolJoes.sol";

/**
 * @title Interface for the OG Migration Workshop contract
 */
interface IOGMigrationWorkshop {
    error SmolJoeWorkshop__InvalidCollectionAddress(address collection);
    error SmolJoeWorkshop__TokenOwnershipRequired();
    error SmolJoeWorkshop__InvalidTokenID();
    error SmolJoeWorkshop__InvalidStartTime();

    event Migration(uint256 indexed tokenID);
    event StartTimeSet(uint256 startTime);

    function smolJoesV2() external view returns (ISmolJoes);

    function originals() external view returns (ISmolJoes);

    function startTime() external view returns (uint256);

    function migrate(uint256 tokenID) external;

    function setStartTime(uint256 startTime) external;

    function pause() external;

    function unpause() external;
}
