// SPDX-License-Identifier: GPL-3.0

/// @title Interface for SmolJoes

pragma solidity ^0.8.6;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";
import {ISmolJoeWorkshop} from "./ISmolJoeWorkshop.sol";
import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";

interface ISmolJoes is IERC721 {
    event DescriptorUpdated(ISmolJoeDescriptorMinimal descriptor);

    event SeederUpdated(ISmolJoeSeeder seeder);

    function dataURI(uint256 tokenId) external returns (string memory);

    function setDescriptor(ISmolJoeDescriptorMinimal descriptor) external;

    function setSeeder(ISmolJoeSeeder seeder) external;

    function mintSpecial(address to, uint256 tokenId, ISmolJoeSeeder.SmolJoeCast upgradeType) external;

    function mint(address to, uint256 amount) external;
}
