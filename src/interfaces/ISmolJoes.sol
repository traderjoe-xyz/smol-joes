// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {IOZNFTBaseUpgradeable} from "nft-base-contracts/OZNFTBaseUpgradeable.sol";

import {ISmolJoeDescriptorMinimal} from "./ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeSeeder} from "./ISmolJoeSeeder.sol";

/**
 * @title Interface for SmolJoes
 */
interface ISmolJoes is IOZNFTBaseUpgradeable {
    error SmolJoes__Unauthorized();
    error SmolJoes__InvalidAddress();
    error SmolJoes__InexistentToken(uint256 tokenId);

    event DescriptorUpdated(address descriptor);
    event SeederUpdated(address seeder);
    event WorkshopUpdated(address workshop);

    function descriptor() external view returns (ISmolJoeDescriptorMinimal);

    function seeder() external view returns (ISmolJoeSeeder);

    function workshop() external view returns (address);

    function getTokenSeed(uint256 tokenId) external view returns (ISmolJoeSeeder.Seed memory);

    function dataURI(uint256 tokenId) external view returns (string memory);

    function setDescriptor(ISmolJoeDescriptorMinimal descriptor) external;

    function setSeeder(ISmolJoeSeeder seeder) external;

    function mint(address to, uint256 amount) external;
}
