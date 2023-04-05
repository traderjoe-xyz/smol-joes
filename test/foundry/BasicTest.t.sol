// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import "./TestHelper.sol";

contract BasicTest is TestHelper {
    function test_Populate() public {
        _populateDescriptor();
    }

    function test_UpdateUniquesArtMapping() public {
        uint8[100] memory artMapping;
        for (uint8 i = 0; i < artMapping.length; i++) {
            artMapping[i] = i + 5;
        }

        seeder.updateSpecialsArtMapping(artMapping);

        for (uint256 i = 0; i < artMapping.length; i++) {
            assertEq(seeder.getSpecialsArtMapping(i), i + 5);
        }
    }
}
