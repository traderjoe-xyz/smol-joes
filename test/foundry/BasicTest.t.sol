// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import "./TestHelper.sol";

contract BasicTest is TestHelper {
    function test_UpdateUniquesArtMapping() public {
        uint16[100] memory artMapping;
        for (uint16 i = 0; i < artMapping.length; i++) {
            artMapping[i] = i + 5;
        }

        seeder.updateUniquesArtMapping(artMapping);

        for (uint256 i = 0; i < artMapping.length; i++) {
            assertEq(seeder.getUniqueArtMapping(i), i + 5);
        }
    }
}
