// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {IOZNFTBaseUpgradeable} from "@traderjoe-xyz/nft-base-contracts/src/OZNFTBaseUpgradeable.sol";

import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";
import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";

/**
 * @title Interface for SmolJoes
 */
interface ISmolJoes is IOZNFTBaseUpgradeable {
    event DescriptorUpdated(address descriptor);
    event SeederUpdated(address seeder);
    event WorkshopUpdated(address workshop);

    error SmolJoes__Unauthorized();

    function dataURI(uint256 tokenId) external returns (string memory);

    function mint(address to, uint256 tokenId) external;

    function setDescriptor(ISmolJoeDescriptorMinimal descriptor) external;

    function setSeeder(ISmolJoeSeeder seeder) external;

    function setWorkshop(address workshop) external;
}
