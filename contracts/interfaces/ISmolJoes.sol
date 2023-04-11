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
    event DescriptorUpdated(ISmolJoeDescriptorMinimal descriptor);
    event SeederUpdated(ISmolJoeSeeder seeder);

    function dataURI(uint256 tokenId) external returns (string memory);

    function setDescriptor(ISmolJoeDescriptorMinimal descriptor) external;

    function setSeeder(ISmolJoeSeeder seeder) external;

    function mint(address to, uint256 amount) external;
}
