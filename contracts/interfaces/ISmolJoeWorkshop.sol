// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {ISmolJoes} from "./ISmolJoes.sol";

/**
 * @title Interface for the Workshop contract
 */
interface ISmolJoeWorkshop {
    error SmolJoeWorkshop__InvalidCollectionAddress(address collection);
    error SmolJoeWorkshop__InvalidInputLength();
    error SmolJoeWorkshop__WithdrawalFailed();
    error SmolJoeWorkshop__InvalidType();
    error SmolJoeWorkshop__InsufficientAvaxPaid();
    error SmolJoeWorkshop__TokenOwnershipRequired();
    error SmolJoeWorkshop__UpgradeNotEnabled();

    /**
     * @dev Type of the NFT to upgrade. Can be a Smol Joe V1, or a Smol Creep
     * Smol Creeps are divided into categories that will have different upgrade prices
     * and will yield a different amount of new Smol Joes:
     * - Bone Creep: 1 for 1 AVAX
     * - Zombie Creep: 2 for 2 AVAX
     * - Gold Creep: 2 for 2 AVAX
     * - Diamond Creep: 3 for 3 AVAX
     * - Unique Creep: 1 Luminary for 5 AVAX
     */

    enum Type {
        SmolJoe,
        Bone,
        Zombie,
        Gold,
        Diamond,
        Unique
    }

    /**
     * @dev Sale will be in 4 phases:
     * 1. The Smol Joes can be upgraded
     * 2. The unique Smol Creeps can be upgraded with a Beeg Pumpkin
     * 3. The generative Smol Creeps can be upgraded with a Smol Pumpkin (generative = Bone, Zombie, Gold, Diamond)
     * 4. The Smol Creeps can be upgraded without a Pumpkin
     */
    enum StartTimes {
        SmolJoe,
        UniqueCreep,
        GenerativeCreep,
        NoPumpkins
    }

    function smolJoesV2() external view returns (ISmolJoes);

    function smolJoesV1() external view returns (IERC721);

    function smolCreeps() external view returns (IERC721);

    function smolPumpkins() external view returns (IERC721);

    function beegPumpkins() external view returns (IERC721);

    function globalEndTime() external view returns (uint64);

    function getCreepType(uint256 creepId) external pure returns (Type);

    function getUpgradePrice(Type category) external view returns (uint256);

    function getSmolsYielded(Type category) external view returns (uint256);

    function getUpgradeStartTime(StartTimes category) external view returns (uint256);

    function upgradeSmolJoe(uint256 smolJoeId) external payable;

    function batchUpgradeSmolJoe(uint256[] calldata smolJoeIds) external payable;

    function upgradeCreepWithBeegPumpkin(uint256 creepId, uint256 beegPumpkinId) external payable;

    function batchUpgradeCreepWithBeegPumpkin(uint256[] calldata creepIds, uint256[] calldata beegPumpkinIds)
        external
        payable;

    function upgradeCreepWithSmolPumpkin(uint256 creepId, uint256 smolPumpkinId) external payable;

    function batchUpgradeCreepWithSmolPumpkin(uint256[] calldata creepIds, uint256[] calldata smolPumpkinIds)
        external
        payable;

    function upgradeCreep(uint256 creepId) external payable;

    function batchUpgradeCreep(uint256[] calldata creepIds) external payable;

    function setUpgradeStartTime(StartTimes category, uint256 timestamp) external;

    function setGlobalEndTime(uint64 timestamp) external;

    function setUpgradePrice(Type category, uint256 price) external;

    function pause() external;

    function unpause() external;

    function withdrawAvax(address to, uint256 amount) external;
}
