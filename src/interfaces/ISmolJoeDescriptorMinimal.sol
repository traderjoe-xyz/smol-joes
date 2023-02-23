// SPDX-License-Identifier: GPL-3.0

/// @title Common interface for SmolJoeDescriptor versions, as used by SmolJoes and SmolJoeSeeder.

pragma solidity ^0.8.6;

import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";

interface ISmolJoeDescriptorMinimal {
    ///
    /// USED BY TOKEN
    ///

    function tokenURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed) external view returns (string memory);

    function dataURI(uint256 tokenId, ISmolJoeSeeder.Seed memory seed) external view returns (string memory);

    ///
    /// USED BY SEEDER
    ///

    function backgroundCount() external view returns (uint256);

    function bodyCount() external view returns (uint256);

    function headCount() external view returns (uint256);
}
