// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./TestHelper.sol";

contract WorkshopTest is TestHelper {
    using stdStorage for StdStorage;

    SmolJoeWorkshop workshop;

    address smolJoesV1 = 0xC70DF87e1d98f6A531c8E324C9BCEC6FC82B5E8d;
    address smolCreeps = 0x2cD4DbCbfC005F8096C22579585fB91097D8D259;
    address beegPumpkins = 0x2b1c0aAb330741FE3f71Fb5434142f1f7Bb6b462;
    address smolPumpkins = 0x62254542187211B521bc93E4AA24629Fc01a699c;

    // forgefmt: disable-next-item
    uint8[800] private creepTypes = [
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

    function setUp() public override {
        vm.createSelectFork(StdChains.getChain("avalanche").rpcUrl, 29039560);

        super.setUp();

        _populateDescriptor(descriptor);

        workshop = new SmolJoeWorkshop(
           smolJoesV1,address(token),smolCreeps,smolPumpkins, beegPumpkins
        );

        token.setWorkshop(address(workshop));

        uint64 currentBlockTimestamp = uint64(block.timestamp);

        workshop.setGlobalEndTime(currentBlockTimestamp + uint64(8 * 7 days));
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.SmolJoe, currentBlockTimestamp + 1 days);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.UniqueCreep, currentBlockTimestamp + 3 days);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.GenerativeCreep, currentBlockTimestamp + 7 days);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.NoPumpkins, currentBlockTimestamp + 42 days);
    }

    function test_Initialization() public {
        vm.createSelectFork(StdChains.getChain("avalanche").rpcUrl, 29039560);

        setUp();

        workshop = new SmolJoeWorkshop(
           smolJoesV1,address(token),smolCreeps,smolPumpkins, beegPumpkins
        );

        token.setWorkshop(address(workshop));

        uint64 currentBlockTimestamp = uint64(block.timestamp);

        workshop.setGlobalEndTime(currentBlockTimestamp + uint64(8 * 7 days));
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.SmolJoe, currentBlockTimestamp + 1 days);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.UniqueCreep, currentBlockTimestamp + 3 days);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.GenerativeCreep, currentBlockTimestamp + 7 days);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.NoPumpkins, currentBlockTimestamp + 42 days);

        assertEq(workshop.globalEndTime(), currentBlockTimestamp + uint64(8 * 7 days), "test_Initialization::1");
        assertEq(
            workshop.getUpgradeStartTime(ISmolJoeWorkshop.StartTimes.SmolJoe),
            currentBlockTimestamp + 1 days,
            "test_Initialization::2"
        );
        assertEq(
            workshop.getUpgradeStartTime(ISmolJoeWorkshop.StartTimes.UniqueCreep),
            currentBlockTimestamp + 3 days,
            "test_Initialization::3"
        );
        assertEq(
            workshop.getUpgradeStartTime(ISmolJoeWorkshop.StartTimes.GenerativeCreep),
            currentBlockTimestamp + 7 days,
            "test_Initialization::4"
        );
        assertEq(
            workshop.getUpgradeStartTime(ISmolJoeWorkshop.StartTimes.NoPumpkins),
            currentBlockTimestamp + 42 days,
            "test_Initialization::5"
        );

        assertEq(workshop.getUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe), 5 ether, "test_Initialization::6");
        assertEq(workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Unique), 5 ether, "test_Initialization::7");
        assertEq(workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Bone), 1 ether, "test_Initialization::8");
        assertEq(workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Zombie), 2 ether, "test_Initialization::9");
        assertEq(workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Gold), 2 ether, "test_Initialization::10");
        assertEq(workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Diamond), 3 ether, "test_Initialization::11");

        assertEq(address(workshop.smolJoesV1()), smolJoesV1, "test_Initialization::12");
        assertEq(address(workshop.smolCreeps()), smolCreeps, "test_Initialization::13");
        assertEq(address(workshop.smolPumpkins()), smolPumpkins, "test_Initialization::14");
        assertEq(address(workshop.beegPumpkins()), beegPumpkins, "test_Initialization::15");
    }

    function test_CreepTypes() public {
        for (uint256 i = 0; i < creepTypes.length; i++) {
            assertEq(uint8(workshop.getCreepType(i)), creepTypes[i], "test_CreepTypes::1");
        }
    }

    function test_UpgradeSmolJoe() public {
        _takeOwnership(smolJoesV1, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe);

        skip(1 days);
        workshop.upgradeSmolJoe{value: price}(0);

        assertEq(token.ownerOf(0), address(this));
    }

    function test_revert_UpgradeSmolJoe() public {
        _takeOwnership(smolJoesV1, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe);

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeSmolJoe{value: price}(0);

        skip(1 days);

        // Can't upgrade without paying, or paying too much
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.upgradeSmolJoe(0);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.upgradeSmolJoe{value: price - 1}(0);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.upgradeSmolJoe{value: price + 1}(0);

        // Can't upgrade a Smol Joe that people don't own
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.upgradeSmolJoe{value: price}(1);

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.upgradeSmolJoe{value: price}(0);

        workshop.unpause();

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeSmolJoe{value: price}(0);
    }

    function test_BatchUpgradeSmolJoe() public {
        uint256[] memory smolJoeIds = new uint256[](2);
        smolJoeIds[0] = 0;
        smolJoeIds[1] = 1;

        _takeOwnership(smolJoesV1, smolJoeIds[0]);
        _takeOwnership(smolJoesV1, smolJoeIds[1]);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe);

        skip(1 days);
        workshop.batchUpgradeSmolJoe{value: smolJoeIds.length * price}(smolJoeIds);

        assertEq(token.ownerOf(0), address(this));
        assertEq(token.ownerOf(1), address(this));
    }

    function test_revert_BatchUpgradeSmolJoe() public {
        uint256[] memory smolJoeIds = new uint256[](2);
        smolJoeIds[0] = 0;
        smolJoeIds[1] = 1;

        _takeOwnership(smolJoesV1, smolJoeIds[0]);
        _takeOwnership(smolJoesV1, smolJoeIds[1]);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe);

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeSmolJoe{value: smolJoeIds.length * price}(smolJoeIds);

        skip(1 days);

        // Can't upgrade without paying for all the upgrades
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.batchUpgradeSmolJoe{value: price}(smolJoeIds);

        // Can't upgrade a Smol Joe that people don't own
        smolJoeIds[1] = 2;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.batchUpgradeSmolJoe{value: smolJoeIds.length * price}(smolJoeIds);

        smolJoeIds[1] = 1;

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.batchUpgradeSmolJoe{value: smolJoeIds.length * price}(smolJoeIds);

        workshop.unpause();

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeSmolJoe{value: smolJoeIds.length * price}(smolJoeIds);
    }

    function test_UpgradeCreepWithBeegPumpkin() public {
        uint256 uniqueCreepId = 0;

        _takeOwnership(smolCreeps, uniqueCreepId);
        _takeOwnership(beegPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Unique);

        skip(3 days);
        workshop.upgradeCreepWithBeegPumpkin{value: price}(uniqueCreepId, 0);

        assertEq(token.ownerOf(100), address(this));
    }

    function test_revert_UpgradeCreepWithBeegPumpkin() public {
        uint256 uniqueCreepId = 0;

        _takeOwnership(smolCreeps, uniqueCreepId);
        _takeOwnership(beegPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Unique);

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeCreepWithBeegPumpkin{value: price}(uniqueCreepId, 0);

        skip(3 days);

        // Can't upgrade without paying
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.upgradeCreepWithBeegPumpkin(uniqueCreepId, 0);

        // Can't upgrade a Creep that people don't own
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.upgradeCreepWithBeegPumpkin{value: price}(1, 0);

        // Can't upgrade using a Beeg Pumpkin that people don't own
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.upgradeCreepWithBeegPumpkin{value: price}(uniqueCreepId, 1);

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.upgradeCreepWithBeegPumpkin{value: price}(uniqueCreepId, 0);

        workshop.unpause();

        // Can't upgrade if the Smol Creep is not unique
        _takeOwnership(smolCreeps, 1);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InvalidType.selector);
        workshop.upgradeCreepWithBeegPumpkin{value: price}(1, 0);

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeCreepWithBeegPumpkin{value: price}(uniqueCreepId, 0);
    }

    function test_BatchUpgradeCreepWithBeegPumpkin() public {
        uint256[] memory uniqueCreepIds = new uint256[](2);
        uniqueCreepIds[0] = 0;
        uniqueCreepIds[1] = 29;

        uint256[] memory beegPumpkinIds = new uint256[](2);
        beegPumpkinIds[0] = 0;
        beegPumpkinIds[1] = 1;

        _takeOwnership(smolCreeps, uniqueCreepIds[0]);
        _takeOwnership(smolCreeps, uniqueCreepIds[1]);
        _takeOwnership(beegPumpkins, beegPumpkinIds[0]);
        _takeOwnership(beegPumpkins, beegPumpkinIds[1]);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Unique);

        skip(3 days);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);

        assertEq(token.ownerOf(100), address(this));
    }

    function test_revert_BatchUpgradeCreepWithBeegPumpkin() public {
        uint256[] memory uniqueCreepIds = new uint256[](2);
        uniqueCreepIds[0] = 0;
        uniqueCreepIds[1] = 29;

        uint256[] memory beegPumpkinIds = new uint256[](2);
        beegPumpkinIds[0] = 0;
        beegPumpkinIds[1] = 1;

        _takeOwnership(smolCreeps, uniqueCreepIds[0]);
        _takeOwnership(smolCreeps, uniqueCreepIds[1]);
        _takeOwnership(beegPumpkins, beegPumpkinIds[0]);
        _takeOwnership(beegPumpkins, beegPumpkinIds[1]);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Unique);

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);

        skip(3 days);

        // Can't upgrade without paying
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: price}(uniqueCreepIds, beegPumpkinIds);

        // Can't upgrade a Creep that people don't own
        uniqueCreepIds[1] = 28;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);

        uniqueCreepIds[1] = 29;

        // Can't upgrade using a Beeg Pumpkin that people don't own
        beegPumpkinIds[1] = 2;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);

        beegPumpkinIds[1] = 1;

        // Can't upgrade if the Smol Creep is not unique
        _takeOwnership(smolCreeps, 1);
        uniqueCreepIds[1] = 1;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InvalidType.selector);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);

        uniqueCreepIds[1] = 29;

        // Can't upgrade if the two arrays are not the same length
        uint256[] memory invalidBeegPumpkinIds = new uint256[](1);
        invalidBeegPumpkinIds[0] = 0;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InvalidInputLength.selector);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(
            uniqueCreepIds, invalidBeegPumpkinIds
        );

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);

        workshop.unpause();

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);
    }

    function test_UpgradeCreepWithSmolPumpkin_Bone() public {
        uint256 boneCreepId = 2;

        _takeOwnership(smolCreeps, boneCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Bone);

        skip(7 days);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(boneCreepId, 0);

        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(200), address(this));
    }

    function test_UpgradeCreepWithSmolPumpkin_Zombie() public {
        uint256 zombieCreepId = 17;

        _takeOwnership(smolCreeps, zombieCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Zombie);

        skip(7 days);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(zombieCreepId, 0);

        assertEq(token.balanceOf(address(this)), 2);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
    }

    function test_UpgradeCreepWithSmolPumpkin_Gold() public {
        uint256 goldCreepId = 8;

        _takeOwnership(smolCreeps, goldCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Gold);

        skip(7 days);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(goldCreepId, 0);

        assertEq(token.balanceOf(address(this)), 2);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
    }

    function test_UpgradeCreepWithSmolPumpkin_Diamond() public {
        uint256 diamondCreepId = 9;

        _takeOwnership(smolCreeps, diamondCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Diamond);

        skip(7 days);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(diamondCreepId, 0);

        assertEq(token.balanceOf(address(this)), 3);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
        assertEq(token.ownerOf(202), address(this));
    }

    function test_revert_UpgradeCreepWithSmolPumpkin() public {
        uint256 boneCreepId = 2;

        _takeOwnership(smolCreeps, boneCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Bone);

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(boneCreepId, 0);

        skip(7 days);

        // Can't upgrade without paying
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.upgradeCreepWithSmolPumpkin{value: price - 1}(boneCreepId, 0);

        // Can't upgrade with a Smol Creep that people don't own
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(3, 0);

        // Can't upgrade with a Smol Pumpkin that people don't own
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(boneCreepId, 3);

        // Can't upgrade if the Smol Creep is not a valid type (unique)
        _takeOwnership(smolCreeps, 0);
        uint256 uniqueCreepUpgradePrice = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Unique);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InvalidType.selector);
        workshop.upgradeCreepWithSmolPumpkin{value: uniqueCreepUpgradePrice}(0, 0);

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.upgradeCreepWithSmolPumpkin{value: price}(boneCreepId, 0);

        workshop.unpause();

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(boneCreepId, 0);
    }

    function test_BatchUpgradeCreepWithSmolPumpkin() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 2;
        tokenIds[1] = 17;
        tokenIds[2] = 8;

        uint256[] memory smolPumpkinIds = new uint256[](3);
        smolPumpkinIds[0] = 0;
        smolPumpkinIds[1] = 1;
        smolPumpkinIds[2] = 2;

        _takeOwnership(smolCreeps, tokenIds[0]);
        _takeOwnership(smolCreeps, tokenIds[1]);
        _takeOwnership(smolCreeps, tokenIds[2]);

        _takeOwnership(smolPumpkins, smolPumpkinIds[0]);
        _takeOwnership(smolPumpkins, smolPumpkinIds[1]);
        _takeOwnership(smolPumpkins, smolPumpkinIds[2]);

        uint256 totalPrice;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type(uint8(workshop.getCreepType(tokenIds[i]))));
            totalPrice += price;
        }

        skip(7 days);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice}(tokenIds, smolPumpkinIds);

        uint256 yieldExpected;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 amount = workshop.getSmolsYielded(workshop.getCreepType(tokenIds[i]));
            yieldExpected += amount;
        }

        assertEq(token.balanceOf(address(this)), yieldExpected);
    }

    function test_revert_BatchUpgradeCreepWithSmolPumpkin() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 2;
        tokenIds[1] = 17;
        tokenIds[2] = 8;

        uint256[] memory smolPumpkinIds = new uint256[](3);
        smolPumpkinIds[0] = 0;
        smolPumpkinIds[1] = 1;
        smolPumpkinIds[2] = 2;

        _takeOwnership(smolCreeps, tokenIds[0]);
        _takeOwnership(smolCreeps, tokenIds[1]);
        _takeOwnership(smolCreeps, tokenIds[2]);

        _takeOwnership(smolPumpkins, smolPumpkinIds[0]);
        _takeOwnership(smolPumpkins, smolPumpkinIds[1]);
        _takeOwnership(smolPumpkins, smolPumpkinIds[2]);

        uint256 totalPrice;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 unitPrice =
                workshop.getUpgradePrice(ISmolJoeWorkshop.Type(uint8(workshop.getCreepType(tokenIds[i]))));
            totalPrice += unitPrice;
        }

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice}(tokenIds, smolPumpkinIds);

        skip(7 days);

        // Can't upgrade without paying
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice - 1}(tokenIds, smolPumpkinIds);

        // Can't upgrade with a Smol Creep that people don't own
        tokenIds[2] = 12;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice}(tokenIds, smolPumpkinIds);

        tokenIds[2] = 8;

        // Can't upgrade with a Smol Pumpkin that people don't own
        smolPumpkinIds[2] = 3;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice}(tokenIds, smolPumpkinIds);

        smolPumpkinIds[2] = 2;

        // Can't upgrade with an invalid Smol Creep type
        uint256 price = totalPrice
            - workshop.getUpgradePrice(ISmolJoeWorkshop.Type(uint8(workshop.getCreepType(tokenIds[2]))))
            + workshop.getUpgradePrice(ISmolJoeWorkshop.Type(uint8(workshop.getCreepType(0))));

        tokenIds[2] = 0;
        _takeOwnership(smolCreeps, tokenIds[2]);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InvalidType.selector);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: price}(tokenIds, smolPumpkinIds);

        tokenIds[2] = 2;

        // Can't upgrade with invalid array lengths
        uint256[] memory invalidSmolPumpkinIds = new uint256[](2);
        smolPumpkinIds[0] = 0;
        smolPumpkinIds[1] = 1;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InvalidInputLength.selector);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice}(tokenIds, invalidSmolPumpkinIds);

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice}(tokenIds, smolPumpkinIds);

        workshop.unpause();

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeCreepWithSmolPumpkin{value: totalPrice}(tokenIds, smolPumpkinIds);
    }

    function test_UpgradeCreep_Unique() public {
        uint256 uniqueCreepId = 0;

        _takeOwnership(smolCreeps, uniqueCreepId);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Unique);

        skip(42 days);
        workshop.upgradeCreep{value: price}(uniqueCreepId);

        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(100), address(this));
    }

    function test_UpgradeCreep_Bone() public {
        uint256 boneCreepId = 2;

        _takeOwnership(smolCreeps, boneCreepId);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Bone);

        skip(42 days);
        workshop.upgradeCreep{value: price}(boneCreepId);

        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(200), address(this));
    }

    function test_UpgradeCreep_Zombie() public {
        uint256 zombieCreepId = 17;

        _takeOwnership(smolCreeps, zombieCreepId);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Zombie);

        skip(42 days);
        workshop.upgradeCreep{value: price}(zombieCreepId);

        assertEq(token.balanceOf(address(this)), 2);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
    }

    function test_UpgradeCreep_Gold() public {
        uint256 goldCreepId = 8;

        _takeOwnership(smolCreeps, goldCreepId);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Gold);

        skip(42 days);
        workshop.upgradeCreep{value: price}(goldCreepId);

        assertEq(token.balanceOf(address(this)), 2);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
    }

    function test_UpgradeCreep_Diamond() public {
        uint256 diamondCreepId = 9;

        _takeOwnership(smolCreeps, diamondCreepId);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Diamond);

        skip(42 days);
        workshop.upgradeCreep{value: price}(diamondCreepId);

        assertEq(token.balanceOf(address(this)), 3);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
        assertEq(token.ownerOf(202), address(this));
    }

    function test_revert_UpgradeCreep() public {
        uint256 diamondCreepId = 9;

        _takeOwnership(smolCreeps, diamondCreepId);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.Diamond);

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeCreep{value: price}(diamondCreepId);

        skip(42 days);

        // Can't upgrade without paying
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.upgradeCreep{value: price - 1}(diamondCreepId);

        // Can't upgrade with a Smol Creep that people don't own
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.upgradeCreep{value: price}(1);

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.upgradeCreep{value: price}(diamondCreepId);

        workshop.unpause();

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.upgradeCreep{value: price}(diamondCreepId);
    }

    function test_BatchUpgradeCreep() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 2;
        tokenIds[1] = 17;
        tokenIds[2] = 8;

        _takeOwnership(smolCreeps, tokenIds[0]);
        _takeOwnership(smolCreeps, tokenIds[1]);
        _takeOwnership(smolCreeps, tokenIds[2]);

        uint256 totalPrice;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type(uint8(workshop.getCreepType(tokenIds[i]))));
            totalPrice += price;
        }

        skip(42 days);
        workshop.batchUpgradeCreep{value: totalPrice}(tokenIds);

        uint256 yieldExpected;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 amount = workshop.getSmolsYielded(workshop.getCreepType(tokenIds[i]));
            yieldExpected += amount;
        }

        assertEq(token.balanceOf(address(this)), yieldExpected);
    }

    function test_revert_BatchUpgradeCreep() public {
        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 2;
        tokenIds[1] = 17;
        tokenIds[2] = 8;

        _takeOwnership(smolCreeps, tokenIds[0]);
        _takeOwnership(smolCreeps, tokenIds[1]);
        _takeOwnership(smolCreeps, tokenIds[2]);

        uint256 totalPrice;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type(uint8(workshop.getCreepType(tokenIds[i]))));
            totalPrice += price;
        }

        // Can't upgrade before start time
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeCreep{value: totalPrice}(tokenIds);

        skip(42 days);

        // Can't upgrade without paying
        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__InsufficientAvaxPaid.selector);
        workshop.batchUpgradeCreep{value: totalPrice - 1}(tokenIds);

        // Can't upgrade with a Smol Creep that people don't own
        tokenIds[0] = 3;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__TokenOwnershipRequired.selector);
        workshop.batchUpgradeCreep{value: totalPrice}(tokenIds);

        tokenIds[0] = 2;

        // Can't upgrade if the contract is paused
        workshop.pause();

        vm.expectRevert("Pausable: paused");
        workshop.batchUpgradeCreep{value: totalPrice}(tokenIds);

        workshop.unpause();

        // Can't upgrade if the end time has passed
        uint256 endTime = workshop.globalEndTime();

        vm.warp(endTime + 1 days);

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__UpgradeNotEnabled.selector);
        workshop.batchUpgradeCreep{value: totalPrice}(tokenIds);
    }

    function test_SetUpgradeStartTime(uint64 newStartTime, uint8 category_) public {
        ISmolJoeWorkshop.StartTimes category = ISmolJoeWorkshop.StartTimes(uint8(bound(category_, 0, 3)));

        workshop.setUpgradeStartTime(category, newStartTime);

        assertEq(workshop.getUpgradeStartTime(category), newStartTime, "test_SetUpgradeStartTime::1");
    }

    function test_revert_SetUpgradeStartTime() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.SmolJoe, 0);
    }

    function test_SetUpgradePrice(uint256 newPrice, uint8 category_) public {
        ISmolJoeWorkshop.Type category = ISmolJoeWorkshop.Type(uint8(bound(category_, 0, 5)));

        workshop.setUpgradePrice(category, newPrice);

        assertEq(workshop.getUpgradePrice(category), newPrice, "test_SetUpgradePrice::1");
    }

    function test_revert_SetUpgradePrice() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        workshop.setUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe, 0);
    }

    function test_SetGlobalEndTime(uint64 newEndTime) public {
        workshop.setGlobalEndTime(newEndTime);

        assertEq(workshop.globalEndTime(), newEndTime, "test_SetGlobalEndTime::1");
    }

    function test_revert_SetGlobalEndTime() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        workshop.setGlobalEndTime(0);
    }

    function test_WithdrawAVAX() public {
        _takeOwnership(smolJoesV1, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe);

        skip(1 days);
        workshop.upgradeSmolJoe{value: price}(0);

        uint256 balanceBefore = address(this).balance;

        workshop.withdrawAvax(address(this), 0);

        uint256 balanceAfter = address(this).balance;

        assertEq(balanceAfter - balanceBefore, price, "test_WithdrawAVAX::1");
    }

    function test_revert_WithdrawAVAX() public {
        _takeOwnership(smolJoesV1, 0);

        uint256 price = workshop.getUpgradePrice(ISmolJoeWorkshop.Type.SmolJoe);

        skip(1 days);
        workshop.upgradeSmolJoe{value: price}(0);

        // Can't withdraw if not the owner
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        workshop.withdrawAvax(address(this), 0);

        // Can't withdraw if the receiver can't receive AVAX
        revertReceive = true;

        vm.expectRevert(ISmolJoeWorkshop.SmolJoeWorkshop__WithdrawalFailed.selector);
        workshop.withdrawAvax(address(this), 0);
    }

    function test_Pause() public {
        workshop.pause();

        assertTrue(workshop.paused(), "test_Pause::1");
    }

    function test_revert_Pause() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        workshop.pause();
    }

    function test_Unpause() public {
        workshop.pause();
        workshop.unpause();

        assertTrue(!workshop.paused(), "test_Unpause::1");
    }

    function test_revert_Unpause() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        workshop.unpause();
    }

    function _takeOwnership(address collection, uint256 tokenId) internal {
        address owner = IERC721(collection).ownerOf(tokenId);

        vm.prank(owner);
        IERC721(collection).transferFrom(owner, address(this), tokenId);

        IERC721(collection).approve(address(workshop), tokenId);
    }

    bool revertReceive;

    receive() external payable {
        if (revertReceive) {
            revert("revertReceive");
        }
    }
}
