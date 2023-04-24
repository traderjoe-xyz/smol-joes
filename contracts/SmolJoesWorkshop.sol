// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import {ISmolJoes} from "./interfaces/ISmolJoes.sol";

/**
 * @title The SmolJoes Workshop is used to upgrade the original collection and the Smol Creeps into the new Smol Joes
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
contract SmolJoesWorkshop is Ownable2Step, Pausable, ReentrancyGuard {
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

    ISmolJoes public immutable smolJoesV2;

    IERC721 public immutable smolJoesV1;
    IERC721 public immutable smolCreeps;
    IERC721 public immutable beegPumpkins;
    IERC721 public immutable smolPumpkins;

    mapping(Type => uint256) private _creepTypeYield;
    mapping(Type => uint256) private _upgradePriceByCategory;
    mapping(StartTimes => uint256) private _startTimeByCategory;

    uint64 public globalEndTime;

    // Luminaries have Ids 100 to 199
    uint8 _lastLuminaryMinted = 99;

    // Smols have Ids from 200
    uint16 _lastSmolMinted = 199;

    address private constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // This list maps each Creep token ID to its Type
    // Creep types have been fetched using the `get-creep-types` task
    // @todo Find a nicer solution ?
    // forgefmt: disable-next-item
    uint8[800] private _creepTypes = [
        5, 4, 1, 1, 1, 1, 1, 1, 3, 4, 1, 1, 3, 3, 1, 3, 1, 2, 1, 1, 1, 4, 1, 4, 2, 2, 1, 1, 1, 5, 1, 1, 5, 1, 3, 1,
        5, 1, 1, 5, 3, 5, 3, 1, 2, 5, 1, 1, 5, 2, 2, 3, 5, 5, 4, 1, 1, 2, 1, 1, 1, 4, 1, 5, 1, 1, 1, 1, 3, 5, 3, 2,
        5, 1, 2, 5, 2, 1, 1, 1, 1, 1, 3, 4, 1, 1, 1, 1, 2, 2, 1, 1, 1, 3, 1, 2, 1, 1, 2, 5, 4, 5, 1, 1, 5, 4, 1, 1,
        1, 1, 1, 5, 4, 3, 2, 1, 3, 1, 4, 4, 5, 3, 3, 4, 5, 3, 5, 2, 4, 1, 1, 3, 1, 1, 2, 1, 5, 5, 3, 1, 4, 3, 3, 1,
        3, 1, 2, 1, 1, 2, 5, 3, 1, 1, 5, 1, 1, 1, 1, 5, 1, 3, 3, 1, 1, 5, 1, 1, 4, 2, 1, 1, 1, 3, 1, 2, 3, 1, 3, 2,
        1, 1, 1, 3, 1, 5, 1, 3, 1, 5, 1, 3, 4, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 5, 1, 1, 2, 1, 1, 1, 1, 1,
        4, 2, 1, 1, 3, 3, 1, 3, 1, 1, 2, 1, 5, 1, 3, 3, 5, 3, 1, 1, 5, 1, 1, 1, 1, 5, 3, 1, 1, 1, 2, 1, 1, 2, 4, 1,
        3, 5, 1, 1, 1, 1, 1, 3, 5, 1, 1, 3, 1, 1, 1, 5, 4, 1, 1, 3, 1, 1, 2, 1, 3, 1, 1, 2, 1, 1, 5, 1, 1, 1, 1, 3,
        4, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 5, 1, 2, 1, 5, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 3, 5, 1, 1, 1, 5, 5, 1, 1, 1,
        1, 1, 1, 4, 2, 1, 4, 1, 1, 5, 2, 1, 2, 1, 1, 4, 5, 2, 1, 1, 3, 1, 1, 5, 5, 1, 2, 5, 2, 1, 1, 1, 4, 5, 5, 4,
        1, 4, 1, 1, 1, 2, 2, 1, 3, 4, 1, 1, 3, 1, 1, 1, 3, 1, 3, 5, 5, 1, 4, 1, 3, 2, 1, 5, 1, 3, 5, 5, 1, 5, 1, 1,
        1, 1, 1, 5, 1, 1, 4, 1, 1, 1, 5, 2, 4, 1, 3, 3, 1, 1, 1, 5, 3, 1, 5, 1, 1, 3, 1, 1, 1, 1, 3, 1, 2, 1, 3, 1,
        5, 1, 1, 2, 3, 1, 2, 5, 1, 5, 2, 1, 2, 5, 3, 1, 1, 5, 3, 2, 1, 2, 1, 4, 1, 1, 3, 1, 5, 1, 1, 3, 1, 3, 1, 1,
        1, 5, 4, 5, 1, 1, 4, 5, 1, 1, 1, 1, 3, 5, 5, 3, 4, 4, 1, 5, 1, 3, 5, 1, 1, 1, 4, 1, 5, 1, 1, 3, 3, 1, 1, 1,
        4, 1, 4, 2, 5, 1, 1, 1, 3, 1, 3, 2, 3, 1, 1, 3, 1, 5, 1, 1, 1, 3, 4, 1, 1, 1, 1, 1, 1, 3, 1, 2, 3, 3, 1, 1,
        3, 3, 3, 4, 1, 1, 1, 3, 5, 1, 1, 2, 1, 3, 3, 3, 1, 1, 5, 4, 1, 1, 1, 1, 5, 5, 1, 1, 1, 5, 1, 5, 1, 5, 1, 3,
        1, 3, 3, 3, 5, 2, 1, 1, 1, 1, 2, 1, 3, 1, 1, 1, 2, 5, 1, 1, 2, 1, 4, 1, 3, 3, 1, 1, 2, 1, 1, 1, 3, 1, 3, 1,
        5, 1, 1, 5, 2, 1, 1, 2, 1, 2, 1, 1, 1, 1, 2, 5, 1, 3, 1, 1, 4, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 3, 1, 1, 1, 3,
        1, 1, 1, 1, 1, 2, 1, 1, 3, 1, 1, 1, 1, 2, 4, 1, 1, 3, 1, 1, 5, 3, 1, 2, 3, 2, 1, 1, 1, 1, 3, 2, 1, 2, 1, 1,
        3, 1, 1, 3, 1, 3, 1, 1, 1, 1, 5, 1, 2, 1, 1, 5, 1, 1, 5, 1, 1, 1, 1, 1, 1, 1, 3, 4, 3, 1, 4, 4, 2, 3, 1, 1,
        5, 2, 4, 1, 3, 1, 1, 1, 3, 4, 1, 1, 1, 1, 1, 1, 3, 1, 1, 2, 1, 1, 2, 4, 1, 3, 1, 2, 1, 5, 1, 1, 1, 5, 1, 1,
        1, 1, 1, 5, 1, 1, 1, 3, 1, 5, 1, 1, 1, 1, 1, 1, 4, 1, 3, 1, 1, 1, 1, 1, 5, 1, 2, 1, 1, 1, 1, 3, 5, 1, 1, 2,
        5, 3, 1, 1, 1, 1, 1, 1
    ];

    // Temporary storage variable to account for the AVAX paid to the contract during a transaction
    // Will be gradually consumed by each upgrade in the batch and is required to be 0 at the end of the transaction
    uint256 private _txBalance;

    modifier isUpgradeEnabled(StartTimes category) {
        uint256 startTime = _startTimeByCategory[category];

        require(
            startTime > 0 && block.timestamp >= startTime && block.timestamp < globalEndTime, "Upgrade is not enabled"
        );
        _;
    }

    modifier handleBalance() {
        _txBalance = msg.value;
        _;
        require(_txBalance == 0, "Balance not consumed entirely");
    }

    constructor(
        address _smolJoesV1,
        address _smolJoesV2,
        address _smolCreeps,
        address _smolPumpkins,
        address _beegPumpkins
    ) {
        require(
            keccak256(bytes(IERC721Metadata(_smolJoesV1).name())) == keccak256("Smol Joes"),
            "Invalid Smol Joes V1 address"
        );

        require(
            keccak256(bytes(IERC721Metadata(_smolJoesV2).name())) == keccak256("Smol Joes Season 2"),
            "Invalid Smol Joes V2 address"
        );

        require(
            keccak256(bytes(IERC721Metadata(_smolCreeps).name())) == keccak256("Smol Creeps"),
            "Invalid Smol Creeps address"
        );

        require(
            keccak256(bytes(IERC721Metadata(_smolPumpkins).name())) == keccak256("Smol Pumpkins"),
            "Invalid Smol Pumpkins address"
        );

        require(
            keccak256(bytes(IERC721Metadata(_beegPumpkins).name())) == keccak256("Beeg Pumpkins"),
            "Invalid Beeg Pumpkins address"
        );

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

    function getCreepType(uint256 tokenId) external view returns (Type) {
        return _getCreepType(tokenId);
    }

    function getUpgradePrice(Type category) external view returns (uint256) {
        return _getUpgradePrice(category);
    }

    function getSmolsYielded(Type category) external view returns (uint256) {
        return _getSmolsYielded(category);
    }

    function getUpgradeStartTime(StartTimes category) external view returns (uint256) {
        return _getUpgradeStartTime(category);
    }

    function upgradeSmolJoe(uint256 tokenId)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.SmolJoe)
        handleBalance
    {
        _upgradeSmolJoe(tokenId);
    }

    function batchUpgradeSmolJoe(uint256[] calldata tokenIds)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.SmolJoe)
        handleBalance
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeSmolJoe(tokenIds[i]);
        }
    }

    function upgradeCreepWithBeegPumpkin(uint256 tokenId, uint256 pumpkinId)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.UniqueCreep)
        handleBalance
    {
        _upgradeCreepWithBeegPumpkin(tokenId, pumpkinId);
    }

    function batchUpgradeCreepWithBeegPumpkin(uint256[] calldata tokenIds, uint256[] calldata pumpkinIds)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.UniqueCreep)
        handleBalance
    {
        require(tokenIds.length == pumpkinIds.length, "Invalid input");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeCreepWithBeegPumpkin(tokenIds[i], pumpkinIds[i]);
        }
    }

    function upgradeCreepWithSmolPumpkin(uint256 tokenId, uint256 pumpkinId)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.GenerativeCreep)
        handleBalance
    {
        _upgradeCreepWithSmolPumpkin(tokenId, pumpkinId);
    }

    function batchUpgradeCreepWithSmolPumpkin(uint256[] calldata tokenIds, uint256[] calldata pumpkinIds)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.GenerativeCreep)
        handleBalance
    {
        require(tokenIds.length == pumpkinIds.length, "Invalid input");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeCreepWithSmolPumpkin(tokenIds[i], pumpkinIds[i]);
        }
    }

    function upgradeCreep(uint256 tokenId)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.NoPumpkins)
        handleBalance
    {
        _upgradeCreep(tokenId);
    }

    function batchUpgradeCreep(uint256[] calldata tokenIds)
        external
        payable
        whenNotPaused
        nonReentrant
        isUpgradeEnabled(StartTimes.NoPumpkins)
        handleBalance
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _upgradeCreep(tokenIds[i]);
        }
    }

    function setUpgradeStartTime(StartTimes upgradeType, uint256 timestamp) external onlyOwner {
        _startTimeByCategory[upgradeType] = timestamp;
    }

    function setUpgradePrice(Type category, uint256 amount) external onlyOwner {
        _upgradePriceByCategory[category] = amount;
    }

    function setGlobalEndTime(uint64 timestamp) external onlyOwner {
        globalEndTime = timestamp;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdrawAvax(address to, uint256 amount) external onlyOwner {
        if (amount == 0 || amount > address(this).balance) {
            amount = address(this).balance;
        }

        (bool success,) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function _upgradeSmolJoe(uint256 tokenId) internal {
        _verifyOwnership(smolJoesV1, tokenId);

        uint256 upgradePrice = _getUpgradePrice(Type.SmolJoe);
        _decrementTxBalance(upgradePrice);

        _burn(smolJoesV1, tokenId);

        _mint(msg.sender, tokenId);
    }

    function _upgradeCreepWithBeegPumpkin(uint256 tokenId, uint256 pumpkinId) internal {
        _verifyOwnership(smolCreeps, tokenId);
        _verifyOwnership(beegPumpkins, pumpkinId);

        Type creepType = _getCreepType(tokenId);
        require(creepType == Type.Unique, "Creep is not unique");

        uint256 upgradePrice = _getUpgradePrice(Type.Unique);
        _decrementTxBalance(upgradePrice);

        _burn(smolCreeps, tokenId);
        _burn(beegPumpkins, pumpkinId);

        _mint(msg.sender, ++_lastLuminaryMinted);
    }

    function _upgradeCreepWithSmolPumpkin(uint256 tokenId, uint256 pumpkinId) internal {
        _verifyOwnership(smolCreeps, tokenId);
        _verifyOwnership(smolPumpkins, pumpkinId);

        Type creepType = _getCreepType(tokenId);

        require(
            creepType == Type.Bone || creepType == Type.Zombie || creepType == Type.Gold || creepType == Type.Diamond,
            "Invalid creep type"
        );

        uint256 upgradePrice = _getUpgradePrice(creepType);
        _decrementTxBalance(upgradePrice);

        _burn(smolCreeps, tokenId);
        _burn(smolPumpkins, pumpkinId);

        uint256 amountMinted = _getSmolsYielded(creepType);

        // @todo cache _lastSmolMinted
        for (uint256 i = 0; i < amountMinted; i++) {
            _mint(msg.sender, ++_lastSmolMinted);
        }
    }

    function _upgradeCreep(uint256 tokenId) internal {
        _verifyOwnership(smolCreeps, tokenId);

        Type creepType = _getCreepType(tokenId);

        uint256 upgradePrice = _getUpgradePrice(creepType);
        _decrementTxBalance(upgradePrice);

        _burn(smolCreeps, tokenId);

        if (creepType == Type.Unique) {
            _mint(msg.sender, ++_lastLuminaryMinted);
        } else {
            uint256 amountMinted = _getSmolsYielded(creepType);

            // @todo cache _lastSmolMinted
            for (uint256 i = 0; i < amountMinted; i++) {
                _mint(msg.sender, ++_lastSmolMinted);
            }
        }
    }

    function _decrementTxBalance(uint256 amount) internal {
        require(_txBalance >= amount, "Insufficient AVAX sent");
        _txBalance -= amount;
    }

    function _verifyOwnership(IERC721 collection, uint256 tokenId) internal view {
        require(collection.ownerOf(tokenId) == msg.sender, "Not owner of token");
    }

    function _getCreepType(uint256 tokenId) internal view returns (Type) {
        return Type(_creepTypes[tokenId]);
    }

    function _getUpgradePrice(Type category) internal view returns (uint256) {
        return _upgradePriceByCategory[category];
    }

    function _getSmolsYielded(Type creepType) internal view returns (uint256) {
        return _creepTypeYield[creepType];
    }

    function _getUpgradeStartTime(StartTimes upgradeType) internal view returns (uint256) {
        return _startTimeByCategory[upgradeType];
    }

    function _mint(address to, uint256 tokenId) internal {
        smolJoesV2.mint(to, tokenId);
    }

    function _burn(IERC721 collection, uint256 tokenId) internal {
        collection.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
    }
}
