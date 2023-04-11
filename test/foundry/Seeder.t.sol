// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./TestHelper.sol";

contract SeederTest is TestHelper {
    function test_UpdateOriginalsArtMapping() public {
        uint8[100] memory artMapping;
        for (uint8 i = 0; i < artMapping.length; i++) {
            artMapping[i] = i + 5;
        }

        seeder.updateOriginalsArtMapping(artMapping);

        for (uint256 i = 0; i < artMapping.length; i++) {
            assertEq(seeder.getOriginalsArtMapping(i), i + 5, "test_UpdateOriginalsArtMapping::1");
        }

        address alice = makeAddr("alice");

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        seeder.updateOriginalsArtMapping(artMapping);
    }

    mapping(ISmolJoeArt.Brotherhood => uint256) brotherhoodCount;
    mapping(ISmolJoeArt.Brotherhood => mapping(uint256 => bool)) idsTaken;
    mapping(ISmolJoeArt.TraitType => mapping(uint256 => uint256)) bodyPartsDistribution;
    mapping(ISmolJoeArt.Brotherhood => uint256) brotherhoodDistribution;

    function test_GenerateSeed() public {
        _populateDescriptor("./test/files/encoded-test-assets/", false);

        seeder.setSmolJoesAddress(address(this));

        ISmolJoeSeeder.Seed memory seed;

        // Originals
        for (uint256 i = 0; i < 100; i++) {
            seed = seeder.generateSeed(i, descriptor);

            assertEq(uint256(seed.brotherhood), 0, "test_GenerateSeed::1");
            assertEq(seed.originalId, seeder.getOriginalsArtMapping(i) + 1, "test_GenerateSeed::2");
        }

        // Luminaries
        for (uint256 i = 100; i < 200; i++) {
            seed = seeder.generateSeed(i, descriptor);

            assertFalse(idsTaken[seed.brotherhood][seed.luminaryId], "test_GenerateSeed::3");

            idsTaken[seed.brotherhood][seed.luminaryId] = true;
            brotherhoodCount[seed.brotherhood]++;
        }

        for (uint256 i = 0; i < 10; i++) {
            assertEq(brotherhoodCount[ISmolJoeArt.Brotherhood(i + 1)], 10, "test_GenerateSeed::4");
        }

        // Smols
        for (uint256 i = 200; i < 10_200; i++) {
            seed = seeder.generateSeed(i, descriptor);

            // Test the URI generation for some of the tokens
            if (i % 100 == 0) {
                descriptor.tokenURI(i, seed);
            }

            brotherhoodDistribution[seed.brotherhood]++;

            bodyPartsDistribution[ISmolJoeArt.TraitType.Background][seed.background]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.Body][seed.body]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.Shoes][seed.shoes]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.Pants][seed.pants]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.Shirt][seed.shirt]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.Beard][seed.beard]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.HairCapHead][seed.hairCapHead]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.EyeAccessory][seed.eyeAccessory]++;
            bodyPartsDistribution[ISmolJoeArt.TraitType.Accessories][seed.accessory]++;
        }

        // Check that all body parts are equally distributed
        for (uint256 i = 0; i < 9; i++) {
            ISmolJoeArt.TraitType traitType = ISmolJoeArt.TraitType(i + 2);

            // Traits on test data have no brotherhood
            uint256 traitTypeAmount = descriptor.traitCount(traitType, ISmolJoeArt.Brotherhood.None);

            for (uint256 j = 0; j < traitTypeAmount; j++) {
                assertApproxEqRel(
                    bodyPartsDistribution[traitType][j],
                    10_000 / traitTypeAmount,
                    5e16, // 5%
                    "test_GenerateSeed::5"
                );
            }
        }

        // Check that all brotherhoods are equally distributed
        for (uint256 i = 0; i < 10; i++) {
            assertApproxEqRel(
                brotherhoodDistribution[ISmolJoeArt.Brotherhood(i + 1)],
                1_000,
                5e16, // 5%
                "test_GenerateSeed::6"
            );
        }
    }

    function test_SetSmolJoesAddress(address newAdress) public {
        vm.assume(newAdress != address(token));

        address alice = makeAddr("alice");

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(alice);
        seeder.setSmolJoesAddress(address(this));

        seeder.setSmolJoesAddress(newAdress);
        assertEq(seeder.smolJoes(), newAdress, "test_SetSmolJoesAddress::1");

        vm.expectRevert(ISmolJoeSeeder.SmolJoeSeeder__InvalidAddress.selector);
        seeder.setSmolJoesAddress(newAdress);

        vm.expectRevert(ISmolJoeSeeder.SmolJoeSeeder__InvalidAddress.selector);
        seeder.setSmolJoesAddress(address(0));
    }
}
