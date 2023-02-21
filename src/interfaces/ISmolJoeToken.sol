// SPDX-License-Identifier: GPL-3.0

/// @title Interface for SmolJoeToken

pragma solidity ^0.8.6;

import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";

interface ISmolJoeToken is IERC721 {
    event DescriptorUpdated(ISmolJoeDescriptorMinimal descriptor);

    event SeederUpdated(ISmolJoeSeeder seeder);

    function dataURI(uint256 tokenId) external returns (string memory);

    function setDescriptor(ISmolJoeDescriptorMinimal descriptor) external;

    function setSeeder(ISmolJoeSeeder seeder) external;
}
