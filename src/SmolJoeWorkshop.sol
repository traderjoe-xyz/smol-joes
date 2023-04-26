// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {Pausable} from "openzeppelin/security/Pausable.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {IERC721Metadata} from "openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";

import {ISmolJoes} from "./interfaces/ISmolJoes.sol";
import {ISmolJoeWorkshop} from "./interfaces/ISmolJoeWorkshop.sol";

/**
 * @title The Smol Joe Workshop is used to upgrade the original collection and the Smol Creeps into the new Smol Joes
 * The upgrade process will be done in 4 phases:
 * 1. Smol Joes can be upgraded for the corresponding Smol Joe V2 from the Hundreds category
 * 2. Unique Smol Creeps can be upgraded with a Beeg Pumpkin for a random Luminary
 * 3. Generative Smol Creeps can be upgraded with a Smol Pumpkin for 1 to 3 new generative Smol Joes
 * 4. Smol Creeps can be upgraded without a Pumpkin much later (same prices and same yields as before)
 *
 * Each upgrade will burn the token used.
 * The price of the upgrade will vary depending on the NFT category:
 * Smol Joe => 5 AVAX to get the corresponding Smol Joe V2, Unique Creep => 5 AVAX to get a random Luminary,
 * Generative Creep => 1 to 3 AVAX to get 1 to 3 new Smol Joes depending on the rarity of the Creep (Bone, Zombie, Gold, Diamond).
 *
 * The different Creep categories will yield different amounts of new Smol Joes:
 * Bone Creep => 1 new Smol Joe, Zombie Creep => 2 new Smol Joes, Gold Creep => 2 new Smol Joes, Diamond Creep => 3 new Smol Joes
 */
contract SmolJoeWorkshop is Ownable2Step, Pausable, ReentrancyGuard, ISmolJoeWorkshop {
    /**
     * @dev Address where the burned tokens are sent
     */
    address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /**
     * @notice The Smol Joes Season 2 contract address
     */
    ISmolJoes public immutable override smolJoesV2;

    /**
     * @notice The Smol Joes Season 1 contract address
     */
    IERC721 public immutable override smolJoesV1;
    /**
     * @notice The Smol Creeps contract address
     */
    IERC721 public immutable override smolCreeps;
    /**
     * @notice The Smol Pumpkins contract address
     */
    IERC721 public immutable override smolPumpkins;
    /**
     * @notice The Beeg Pumpkins contract address
     */
    IERC721 public immutable override beegPumpkins;

    /**
     * @notice The upgrade window end time
     * @dev Each type of NFT will have a different start time but the same end time
     */
    uint64 public override globalEndTime;

    /**
     * @dev Luminaries have Ids 100 to 199
     */
    uint8 private _lastLuminaryMinted = 99;

    /**
     * @dev Smols have Ids starting from 200
     */
    uint16 private _lastSmolMinted = 199;

    /**
     * @dev The amount of Smols that will be minted for each type of Smol Creep
     */
    mapping(Type => uint256) private _creepTypeYield;
    /**
     * @dev The price of upgrading each type of NFT (Smol Joe and each kind of Smol Creep)
     */
    mapping(Type => uint256) private _upgradePriceByCategory;
    /**
     * @dev The start time of the upgrade window for each type of NFT
     */
    mapping(StartTimes => uint256) private _startTimeByCategory;

    /**
     * @dev This bytes string maps each Creep token ID to its Type (two per bytes)
     * Creep types have been fetched using the `get-creep-types` task
     */
    bytes private constant _creepTypes =
        "\x45\x11\x11\x11\x43\x11\x33\x31\x21\x11\x41\x41\x22\x11\x51\x11\x15\x13\x15\x51\x53\x13\x52\x11\x25\x32\x55\x14\x21\x11\x41\x51\x11\x11\x53\x23\x15\x52\x12\x11\x11\x43\x11\x11\x22\x11\x31\x21\x11\x52\x54\x11\x45\x11\x11\x51\x34\x12\x13\x44\x35\x43\x35\x25\x14\x31\x11\x12\x55\x13\x34\x13\x13\x12\x21\x35\x11\x15\x11\x51\x31\x13\x51\x11\x24\x11\x31\x21\x13\x23\x11\x31\x51\x31\x51\x31\x34\x11\x11\x11\x11\x11\x21\x51\x11\x12\x11\x11\x24\x11\x33\x31\x11\x12\x15\x33\x35\x11\x15\x11\x51\x13\x11\x12\x21\x14\x53\x11\x11\x31\x15\x31\x11\x51\x14\x31\x11\x12\x13\x21\x11\x15\x11\x31\x14\x13\x11\x11\x11\x51\x21\x51\x12\x11\x12\x11\x12\x53\x11\x51\x15\x11\x11\x41\x12\x14\x51\x12\x12\x41\x25\x11\x13\x51\x15\x52\x12\x11\x54\x45\x41\x11\x21\x12\x43\x11\x13\x11\x13\x53\x15\x14\x23\x51\x31\x55\x51\x11\x11\x51\x11\x14\x11\x25\x14\x33\x11\x51\x13\x15\x31\x11\x11\x13\x12\x13\x15\x21\x13\x52\x51\x12\x52\x13\x51\x23\x21\x41\x11\x13\x15\x31\x31\x11\x51\x54\x11\x54\x11\x11\x53\x35\x44\x51\x31\x15\x11\x14\x15\x31\x13\x11\x14\x24\x15\x11\x13\x23\x13\x31\x51\x11\x31\x14\x11\x11\x31\x21\x33\x11\x33\x43\x11\x31\x15\x21\x31\x33\x11\x45\x11\x11\x55\x11\x51\x51\x51\x31\x31\x33\x25\x11\x11\x12\x13\x11\x52\x11\x12\x14\x33\x11\x12\x11\x13\x13\x15\x51\x12\x21\x21\x11\x11\x52\x31\x11\x14\x11\x11\x21\x11\x32\x11\x31\x11\x11\x21\x11\x13\x11\x21\x14\x31\x11\x35\x21\x23\x11\x11\x23\x21\x11\x13\x31\x31\x11\x11\x15\x12\x51\x11\x15\x11\x11\x11\x43\x13\x44\x32\x11\x25\x14\x13\x11\x43\x11\x11\x11\x13\x21\x11\x42\x31\x21\x51\x11\x51\x11\x11\x51\x11\x31\x51\x11\x11\x11\x14\x13\x11\x11\x15\x12\x11\x31\x15\x21\x35\x11\x11\x11";

    /**
     * @dev Checks if the upgrade is enabled
     * @param category Upgrade category
     */
    modifier isUpgradeEnabled(StartTimes category) {
        uint256 startTime = _startTimeByCategory[category];

        if (startTime == 0 || block.timestamp < startTime || block.timestamp >= globalEndTime) {
            revert SmolJoeWorkshop__UpgradeNotEnabled();
        }

        _;
    }

    /**
     * @dev Contract constructor
     * @param _smolJoesV1 Address of the Smol Joes V1 collection
     * @param _smolJoesV2 Address of the Smol Joes V2 collection
     * @param _smolCreeps Address of the Smol Creeps collection
     * @param _smolPumpkins Address of the Smol Pumpkins collection
     * @param _beegPumpkins Address of the Beeg Pumpkins collection
     */
    constructor(
        address _smolJoesV1,
        address _smolJoesV2,
        address _smolCreeps,
        address _smolPumpkins,
        address _beegPumpkins
    ) {
        if (keccak256(bytes(IERC721Metadata(_smolJoesV1).name())) != keccak256("Smol Joes")) {
            revert SmolJoeWorkshop__InvalidCollectionAddress(_smolJoesV1);
        }

        if (keccak256(bytes(IERC721Metadata(_smolJoesV2).name())) != keccak256("Smol Joes Season 2")) {
            revert SmolJoeWorkshop__InvalidCollectionAddress(_smolJoesV2);
        }

        if (keccak256(bytes(IERC721Metadata(_smolCreeps).name())) != keccak256("Smol Creeps")) {
            revert SmolJoeWorkshop__InvalidCollectionAddress(_smolCreeps);
        }

        if (keccak256(bytes(IERC721Metadata(_smolPumpkins).name())) != keccak256("Smol Pumpkins")) {
            revert SmolJoeWorkshop__InvalidCollectionAddress(_smolPumpkins);
        }

        if (keccak256(bytes(IERC721Metadata(_beegPumpkins).name())) != keccak256("Beeg Pumpkins")) {
            revert SmolJoeWorkshop__InvalidCollectionAddress(_beegPumpkins);
        }

        smolJoesV1 = IERC721(_smolJoesV1);
        smolJoesV2 = ISmolJoes(_smolJoesV2);
        smolCreeps = IERC721(_smolCreeps);
        smolPumpkins = IERC721(_smolPumpkins);
        beegPumpkins = IERC721(_beegPumpkins);

        _upgradePriceByCategory[Type.SmolJoe] = 5 ether;
        _upgradePriceByCategory[Type.Bone] = 1 ether;
        _upgradePriceByCategory[Type.Zombie] = 2 ether;
        _upgradePriceByCategory[Type.Gold] = 2 ether;
        _upgradePriceByCategory[Type.Diamond] = 3 ether;
        _upgradePriceByCategory[Type.Unique] = 5 ether;

        _creepTypeYield[Type.Bone] = 1;
        _creepTypeYield[Type.Zombie] = 2;
        _creepTypeYield[Type.Gold] = 2;
        _creepTypeYield[Type.Diamond] = 3;
    }

    /**
     * @notice Returns the creep type of a given token
     * @param tokenId The token ID
     * @return The creep type
     */
    function getCreepType(uint256 tokenId) external pure override returns (Type) {
        return _getCreepType(tokenId);
    }

    /**
     * @notice Returns the upgrade price for a given category (Smol Joe, Bone Creep, Zombie Creep, etc)
     * @param category The category
     * @return The upgrade price
     */
    function getUpgradePrice(Type category) external view override returns (uint256) {
        return _getUpgradePrice(category);
    }

    /**
     * @notice Returns the amount of smols yielded by a given category
     * @param category The category
     * @return The amount of smols yielded
     */
    function getSmolsYielded(Type category) external view override returns (uint256) {
        return _getSmolsYielded(category);
    }

    /**
     * @notice Returns the upgrade start time for a given category
     * @param category The category
     * @return The upgrade start time
     */
    function getUpgradeStartTime(StartTimes category) external view override returns (uint256) {
        return _getUpgradeStartTime(category);
    }

    /**
     * @notice Burns a Smol Joe V1 NFT and mints the corresponding Smol Joe V2
     * @param tokenId The token ID to burn
     */
    function upgradeSmolJoe(uint256 tokenId)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.SmolJoe)
    {
        _checkPricePaid(Type.SmolJoe);
        _upgradeSmolJoe(tokenId);

        emit SmolJoeUpgrade(msg.value);
    }

    /**
     * @notice Burns a series of Smol Joe V1 NFTs and mints the correspondings Smol Joe V2s
     * @param tokenIds The token IDs array to burn
     */
    function batchUpgradeSmolJoe(uint256[] calldata tokenIds)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.SmolJoe)
    {
        _checkPricePaid(Type.SmolJoe, tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeSmolJoe(tokenIds[i]);
        }

        emit SmolJoeUpgrade(msg.value);
    }

    /**
     * @notice Burns a Unique Creep NFT and a Beeg Pumpkin NFT and mints a random Lumninary from the Smol Joe V2 collection
     * @param tokenId The Unique Creep token ID to burn
     * @param pumpkinId The Beeg Pumpkin token ID to burn
     */
    function upgradeCreepWithBeegPumpkin(uint256 tokenId, uint256 pumpkinId)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.UniqueCreep)
    {
        _checkPricePaid(Type.Unique);
        _upgradeCreepWithBeegPumpkin(tokenId, pumpkinId);

        emit UniqueCreepUpgrade(msg.value);
    }

    /**
     * @notice Burns a series of Unique Creep NFTs and Beeg Pumpkin NFTs and mints random Lumninaries from the Smol Joe V2 collection
     * @param tokenIds The Unique Creep token IDs array to burn
     * @param pumpkinIds The Beeg Pumpkin token IDs array to burn
     */
    function batchUpgradeCreepWithBeegPumpkin(uint256[] calldata tokenIds, uint256[] calldata pumpkinIds)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.UniqueCreep)
    {
        if (tokenIds.length != pumpkinIds.length) {
            revert SmolJoeWorkshop__InvalidInputLength();
        }

        _checkPricePaid(Type.Unique, tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeCreepWithBeegPumpkin(tokenIds[i], pumpkinIds[i]);
        }

        emit UniqueCreepUpgrade(msg.value);
    }

    /**
     * @notice Burns a Smol Creep NFT and a Smol Pumpkin NFT and mints a random Smol (generative) from the Smol Joe V2 collection
     * @param tokenId The Smol Creep token ID to burn
     * @param pumpkinId The Smol Pumpkin token ID to burn
     */
    function upgradeCreepWithSmolPumpkin(uint256 tokenId, uint256 pumpkinId)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.GenerativeCreep)
    {
        _checkPricePaid(_getCreepType(tokenId));
        _upgradeCreepWithSmolPumpkin(tokenId, pumpkinId);

        emit GenerativeCreepUpgrade(msg.value);
    }

    /**
     * @notice Burns a series of Smol Creep NFTs and Smol Pumpkin NFTs and mints random Smols from the Smol Joe V2 collection
     * @param tokenIds The Smol Creep token IDs array to burn
     * @param pumpkinIds The Smol Pumpkin token IDs array to burn
     */
    function batchUpgradeCreepWithSmolPumpkin(uint256[] calldata tokenIds, uint256[] calldata pumpkinIds)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.GenerativeCreep)
    {
        if (tokenIds.length != pumpkinIds.length) {
            revert SmolJoeWorkshop__InvalidInputLength();
        }

        _checkPricePaid(tokenIds);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeCreepWithSmolPumpkin(tokenIds[i], pumpkinIds[i]);
        }

        emit GenerativeCreepUpgrade(msg.value);
    }

    /**
     * @notice Burns a Smol Creep NFT and mints a random Lumninary if it's an unique, or a random Smol if it's a generative
     * `upgradeCreep` without burning a pumpkin NFT will be enabled much later than the other upgrades
     * @param tokenId The Unique Creep token ID to burn
     */
    function upgradeCreep(uint256 tokenId)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.NoPumpkins)
    {
        _checkPricePaid(_getCreepType(tokenId));
        _upgradeCreep(tokenId);

        emit CreepUpgrade(msg.value);
    }

    /**
     * @notice Burns a series of Smol Creep NFTs and mints random Lumninaries if they're uniques, or random Smols if they're generatives
     * `batchUpgradeCreep` without burning a pumpkin NFT will be enabled much later than the other upgrades
     * @param tokenIds The Unique Creep token IDs array to burn
     */
    function batchUpgradeCreep(uint256[] calldata tokenIds)
        external
        payable
        override
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.NoPumpkins)
    {
        _checkPricePaid(tokenIds);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeCreep(tokenIds[i]);
        }

        emit CreepUpgrade(msg.value);
    }

    /**
     * @notice Sets the start time for a specific upgrade type
     * @param upgradeType The upgrade type to set the start time for
     * @param timestamp The timestamp to set the start time to
     */
    function setUpgradeStartTime(StartTimes upgradeType, uint256 timestamp) external override onlyOwner {
        _startTimeByCategory[upgradeType] = timestamp;

        emit UpgradeStartTimeSet(upgradeType, timestamp);
    }

    /**
     * @notice Sets the price for a specific upgrade type
     * @param category The upgrade type to set the price for
     * @param amount The amount to set the price to
     */
    function setUpgradePrice(Type category, uint256 amount) external override onlyOwner {
        _upgradePriceByCategory[category] = amount;

        emit UpgradePriceSet(category, amount);
    }

    /**
     * @notice Sets the global end time, when all the upgrades will be disabled
     * @param timestamp The timestamp to set the global end time to
     */
    function setGlobalEndTime(uint64 timestamp) external override onlyOwner {
        globalEndTime = timestamp;

        emit GlobalEndTimeSet(timestamp);
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
     * @notice Withdraws AVAX from the contract
     * @param to The address to withdraw to
     * @param amount The amount to withdraw
     */
    function withdrawAvax(address to, uint256 amount) external override onlyOwner {
        if (amount == 0) {
            amount = address(this).balance;
        }

        (bool success,) = to.call{value: amount}("");
        if (!success) {
            revert SmolJoeWorkshop__WithdrawalFailed();
        }

        emit AvaxWithdrawn(to, amount);
    }

    /**
     * @dev Verify that the caller owns the token, burn it and mint the corresponding Hundred
     * @param tokenId The token ID to burn
     */
    function _upgradeSmolJoe(uint256 tokenId) internal {
        _verifyOwnership(smolJoesV1, tokenId);

        _burn(smolJoesV1, tokenId);

        _mint(msg.sender, tokenId);
    }

    /**
     * @dev Verify that the caller owns the tokens, burn them and mint the next Luminary (will be randomized by the Seeder contract)
     * @param tokenId The creep token ID to burn
     * @param pumpkinId The pumpkin token ID to burn
     */
    function _upgradeCreepWithBeegPumpkin(uint256 tokenId, uint256 pumpkinId) internal {
        _verifyOwnership(smolCreeps, tokenId);
        _verifyOwnership(beegPumpkins, pumpkinId);

        Type creepType = _getCreepType(tokenId);
        if (creepType != Type.Unique) {
            revert SmolJoeWorkshop__InvalidType();
        }

        _burn(smolCreeps, tokenId);
        _burn(beegPumpkins, pumpkinId);

        _mint(msg.sender, ++_lastLuminaryMinted);
    }

    /**
     * @dev Verify that the caller owns the tokens, burn them and mint the next Smol (will be randomized by the Seeder contract)
     * @param tokenId The creep token ID to burn
     * @param pumpkinId The pumpkin token ID to burn
     */
    function _upgradeCreepWithSmolPumpkin(uint256 tokenId, uint256 pumpkinId) internal {
        _verifyOwnership(smolCreeps, tokenId);
        _verifyOwnership(smolPumpkins, pumpkinId);

        Type creepType = _getCreepType(tokenId);

        if (creepType != Type.Bone && creepType != Type.Zombie && creepType != Type.Gold && creepType != Type.Diamond) {
            revert SmolJoeWorkshop__InvalidType();
        }

        _burn(smolCreeps, tokenId);
        _burn(smolPumpkins, pumpkinId);

        uint256 amountMinted = _getSmolsYielded(creepType);

        uint16 lastSmolMinted = _lastSmolMinted;
        for (uint256 i = 0; i < amountMinted; i++) {
            _mint(msg.sender, ++lastSmolMinted);
        }
        _lastSmolMinted = lastSmolMinted;
    }

    /**
     * @dev Verify that the caller owns the token, burn it and mint the corresponding Luminary or Smol
     * @param tokenId The token ID to burn
     */
    function _upgradeCreep(uint256 tokenId) internal {
        _verifyOwnership(smolCreeps, tokenId);

        Type creepType = _getCreepType(tokenId);

        _burn(smolCreeps, tokenId);

        if (creepType == Type.Unique) {
            _mint(msg.sender, ++_lastLuminaryMinted);
        } else {
            uint256 amountMinted = _getSmolsYielded(creepType);

            uint16 lastSmolMinted = _lastSmolMinted;
            for (uint256 i = 0; i < amountMinted; i++) {
                _mint(msg.sender, ++_lastSmolMinted);
            }
            _lastSmolMinted = lastSmolMinted;
        }
    }

    /**
     * @dev Verify that the correct amount of AVAX was paid
     * @param category The upgrade type to check the price for
     */
    function _checkPricePaid(Type category) internal view {
        if (msg.value != _getUpgradePrice(category)) {
            revert SmolJoeWorkshop__InsufficientAvaxPaid();
        }
    }

    /**
     * @dev Verify that the correct amount of AVAX was paid
     * @param category The upgrade type to check the price for
     * @param amount The amount of token of this type to upgrade
     */
    function _checkPricePaid(Type category, uint256 amount) internal view {
        if (msg.value != amount * _getUpgradePrice(category)) {
            revert SmolJoeWorkshop__InsufficientAvaxPaid();
        }
    }

    /**
     * @dev Verify that the correct amount of AVAX was paid
     * @param tokenIds The token IDs to check the price for
     */
    function _checkPricePaid(uint256[] calldata tokenIds) internal view {
        uint256 totalPrice;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalPrice += _getUpgradePrice(_getCreepType(tokenIds[i]));
        }

        if (msg.value != totalPrice) {
            revert SmolJoeWorkshop__InsufficientAvaxPaid();
        }
    }

    /**
     * @dev Verify that the caller owns the token that is meant to be burnt
     * @param collection The collection to check ownership in
     * @param tokenId The token ID to check ownership for
     */
    function _verifyOwnership(IERC721 collection, uint256 tokenId) internal view {
        if (collection.ownerOf(tokenId) != msg.sender) {
            revert SmolJoeWorkshop__TokenOwnershipRequired();
        }
    }

    /**
     * @dev Gets the creep type of a token
     * Types are packed into the _creepTypes array, 2 per byte
     * Types can't be fetched directly on-chain as they are stored in the NFT metadata on IPFS
     * @param tokenId The token ID to get the creep type for
     */
    function _getCreepType(uint256 tokenId) internal pure returns (Type) {
        uint256 bytePos = tokenId / 2;
        uint256 bitPos = tokenId % 2;

        uint8 byteValue = uint8(_creepTypes[bytePos]);

        return Type((byteValue >> (4 * bitPos)) & 0xf);
    }

    /**
     * @dev Gets the upgrade price for a given upgrade type
     * @param category The upgrade type to get the price for
     */
    function _getUpgradePrice(Type category) internal view returns (uint256) {
        return _upgradePriceByCategory[category];
    }

    /**
     * @dev Gets the amount of Smols yielded by a given creep type
     * @param creepType The creep type to get the yield for
     */
    function _getSmolsYielded(Type creepType) internal view returns (uint256) {
        return _creepTypeYield[creepType];
    }

    /**
     * @dev Gets the timestamp of the start of a given upgrade type
     * @param upgradeType The upgrade type to get the start time for
     */
    function _getUpgradeStartTime(StartTimes upgradeType) internal view returns (uint256) {
        return _startTimeByCategory[upgradeType];
    }

    /**
     * @dev Mints a Smol Joe V2 token
     * The Workshop contract needs to be allowed to mint tokens on behalf of the Smol Joe V2 contract
     * @param to The address to mint the token to
     * @param tokenId The token ID to mint
     */
    function _mint(address to, uint256 tokenId) internal {
        smolJoesV2.mint(to, tokenId);
    }

    /**
     * @dev Burns a token by sending it to `address(dead)`
     * @param collection The collection to burn the token from
     * @param tokenId The token ID to burn
     */
    function _burn(IERC721 collection, uint256 tokenId) internal {
        collection.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
    }
}
