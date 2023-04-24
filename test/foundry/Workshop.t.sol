// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./TestHelper.sol";

contract WorkshopTest is TestHelper {
    using stdStorage for StdStorage;

    SmolJoesWorkshop workshop;

    address smolJoesV1 = 0xC70DF87e1d98f6A531c8E324C9BCEC6FC82B5E8d;
    address smolCreeps = 0x2cD4DbCbfC005F8096C22579585fB91097D8D259;
    address beegPumpkins = 0x2b1c0aAb330741FE3f71Fb5434142f1f7Bb6b462;
    address smolPumpkins = 0x62254542187211B521bc93E4AA24629Fc01a699c;

    function setUp() public override {
        vm.createSelectFork(StdChains.getChain("avalanche").rpcUrl, 29039560);

        super.setUp();

        _populateDescriptor(descriptor);

        workshop = new SmolJoesWorkshop(
           smolJoesV1,address(token),smolCreeps,smolPumpkins, beegPumpkins
        );

        token.setWorkshop(address(workshop));

        uint256 currentBlockTimestamp = block.timestamp;

        workshop.setGlobalEndTime(currentBlockTimestamp + 8 * 7 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.SmolJoe, currentBlockTimestamp + 1 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.UniqueCreep, currentBlockTimestamp + 3 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.GenerativeCreep, currentBlockTimestamp + 7 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.NoPumpkins, currentBlockTimestamp + 42 days);
    }

    function test_Initialization() public {
        vm.createSelectFork(StdChains.getChain("avalanche").rpcUrl, 29039560);

        setUp();

        workshop = new SmolJoesWorkshop(
           smolJoesV1,address(token),smolCreeps,smolPumpkins, beegPumpkins
        );

        token.setWorkshop(address(workshop));

        uint256 currentBlockTimestamp = block.timestamp;

        workshop.setGlobalEndTime(currentBlockTimestamp + 8 * 7 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.SmolJoe, currentBlockTimestamp + 1 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.UniqueCreep, currentBlockTimestamp + 3 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.GenerativeCreep, currentBlockTimestamp + 7 days);
        workshop.setUpgradeStartTime(SmolJoesWorkshop.StartTimes.NoPumpkins, currentBlockTimestamp + 42 days);

        assertEq(workshop.globalEndTime(), currentBlockTimestamp + 8 * 7 days, "test_Initialization::1");
        assertEq(
            workshop.getUpgradeStartTime(SmolJoesWorkshop.StartTimes.SmolJoe),
            currentBlockTimestamp + 1 days,
            "test_Initialization::2"
        );
        assertEq(
            workshop.getUpgradeStartTime(SmolJoesWorkshop.StartTimes.UniqueCreep),
            currentBlockTimestamp + 3 days,
            "test_Initialization::3"
        );
        assertEq(
            workshop.getUpgradeStartTime(SmolJoesWorkshop.StartTimes.GenerativeCreep),
            currentBlockTimestamp + 7 days,
            "test_Initialization::4"
        );
        assertEq(
            workshop.getUpgradeStartTime(SmolJoesWorkshop.StartTimes.NoPumpkins),
            currentBlockTimestamp + 42 days,
            "test_Initialization::5"
        );

        assertEq(workshop.getUpgradePrice(SmolJoesWorkshop.Type.SmolJoe), 5 ether, "test_Initialization::6");
        assertEq(workshop.getUpgradePrice(SmolJoesWorkshop.Type.Unique), 5 ether, "test_Initialization::7");
        assertEq(workshop.getUpgradePrice(SmolJoesWorkshop.Type.Bone), 1 ether, "test_Initialization::8");
        assertEq(workshop.getUpgradePrice(SmolJoesWorkshop.Type.Zombie), 2 ether, "test_Initialization::9");
        assertEq(workshop.getUpgradePrice(SmolJoesWorkshop.Type.Gold), 2 ether, "test_Initialization::10");
        assertEq(workshop.getUpgradePrice(SmolJoesWorkshop.Type.Diamond), 3 ether, "test_Initialization::11");

        assertEq(address(workshop.smolJoesV1()), smolJoesV1, "test_Initialization::12");
        assertEq(address(workshop.smolCreeps()), smolCreeps, "test_Initialization::13");
        assertEq(address(workshop.smolPumpkins()), smolPumpkins, "test_Initialization::14");
        assertEq(address(workshop.beegPumpkins()), beegPumpkins, "test_Initialization::15");
    }

    function test_UpgradeSmolJoe() public {
        _takeOwnership(smolJoesV1, 0);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.SmolJoe);

        skip(1 days);
        workshop.upgradeSmolJoe{value: price}(0);

        assertEq(token.ownerOf(0), address(this));
    }

    function test_BatchUpgradeSmolJoe() public {
        uint256[] memory smolJoeIds = new uint256[](2);
        smolJoeIds[0] = 0;
        smolJoeIds[1] = 1;

        _takeOwnership(smolJoesV1, smolJoeIds[0]);
        _takeOwnership(smolJoesV1, smolJoeIds[1]);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.SmolJoe);

        skip(1 days);
        workshop.batchUpgradeSmolJoe{value: smolJoeIds.length * price}(smolJoeIds);

        assertEq(token.ownerOf(0), address(this));
        assertEq(token.ownerOf(1), address(this));
    }

    function test_UpgradeCreepWithBeegPumpkin() public {
        uint256 uniqueCreepId = 0;

        _takeOwnership(smolCreeps, uniqueCreepId);
        _takeOwnership(beegPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Unique);

        skip(3 days);
        workshop.upgradeCreepWithBeegPumpkin{value: price}(uniqueCreepId, 0);

        assertEq(token.ownerOf(100), address(this));
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

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Unique);

        skip(3 days);
        workshop.batchUpgradeCreepWithBeegPumpkin{value: uniqueCreepIds.length * price}(uniqueCreepIds, beegPumpkinIds);

        assertEq(token.ownerOf(100), address(this));
    }

    function test_UpgradeCreepWithSmolPumpkin_Bone() public {
        uint256 boneCreepId = 2;

        _takeOwnership(smolCreeps, boneCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Bone);

        skip(7 days);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(boneCreepId, 0);

        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(200), address(this));
    }

    function test_UpgradeCreepWithSmolPumpkin_Zombie() public {
        uint256 zombieCreepId = 17;

        _takeOwnership(smolCreeps, zombieCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Zombie);

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

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Gold);

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

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Diamond);

        skip(7 days);
        workshop.upgradeCreepWithSmolPumpkin{value: price}(diamondCreepId, 0);

        assertEq(token.balanceOf(address(this)), 3);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
        assertEq(token.ownerOf(202), address(this));
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
            uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type(uint8(workshop.getCreepType(tokenIds[i]))));
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

    function test_UpgradeCreep_Unique() public {
        uint256 uniqueCreepId = 0;

        _takeOwnership(smolCreeps, uniqueCreepId);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Unique);

        skip(42 days);
        workshop.upgradeCreep{value: price}(uniqueCreepId);

        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(100), address(this));
    }

    function test_UpgradeCreep_Bone() public {
        uint256 boneCreepId = 2;

        _takeOwnership(smolCreeps, boneCreepId);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Bone);

        skip(42 days);
        workshop.upgradeCreep{value: price}(boneCreepId);

        assertEq(token.balanceOf(address(this)), 1);
        assertEq(token.ownerOf(200), address(this));
    }

    function test_UpgradeCreep_Zombie() public {
        uint256 zombieCreepId = 17;

        _takeOwnership(smolCreeps, zombieCreepId);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Zombie);

        skip(42 days);
        workshop.upgradeCreep{value: price}(zombieCreepId);

        assertEq(token.balanceOf(address(this)), 2);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
    }

    function test_UpgradeCreep_Gold() public {
        uint256 goldCreepId = 8;

        _takeOwnership(smolCreeps, goldCreepId);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Gold);

        skip(42 days);
        workshop.upgradeCreep{value: price}(goldCreepId);

        assertEq(token.balanceOf(address(this)), 2);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
    }

    function test_UpgradeCreep_Diamond() public {
        uint256 diamondCreepId = 9;

        _takeOwnership(smolCreeps, diamondCreepId);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Diamond);

        skip(42 days);
        workshop.upgradeCreep{value: price}(diamondCreepId);

        assertEq(token.balanceOf(address(this)), 3);
        assertEq(token.ownerOf(200), address(this));
        assertEq(token.ownerOf(201), address(this));
        assertEq(token.ownerOf(202), address(this));
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
            uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type(uint8(workshop.getCreepType(tokenIds[i]))));
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

    function test_Revert_UpgradeCreepWithSmolPumpkin_Unique() public {
        uint256 uniqueCreepId = 0;

        _takeOwnership(smolCreeps, uniqueCreepId);
        _takeOwnership(smolPumpkins, 0);

        uint256 price = workshop.getUpgradePrice(SmolJoesWorkshop.Type.Unique);

        skip(7 days);

        vm.expectRevert();
        workshop.upgradeCreepWithSmolPumpkin{value: price}(uniqueCreepId, 0);
    }

    function _takeOwnership(address collection, uint256 tokenId) internal {
        address owner = IERC721(collection).ownerOf(tokenId);

        vm.prank(owner);
        IERC721(collection).transferFrom(owner, address(this), tokenId);

        IERC721(collection).approve(address(workshop), tokenId);
    }
}
