// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "../TestHelper.sol";

contract GenerateSVGTest is TestHelper {
    using Strings for uint256;

    function test_Custom_SVGGeneration() public {
        uint256 gasLeft = gasleft();
        _populateDescriptor(descriptor);
        console.log("Gas used to populate descriptor: ", gasLeft - gasleft());

        // forgefmt: disable-next-item
        uint8[100] memory artMapping = [
        43,  2, 55, 11, 74, 68, 34, 90, 14, 53, 23, 77,
        91, 62, 88, 59, 51,  3, 49, 93, 44, 31, 36, 21,
        6, 84,  5, 70, 92, 99, 97, 98, 46, 38, 33, 12,
        95, 54, 30, 96, 76, 20, 15, 28, 35, 82, 45, 75,
        0, 83, 19, 58, 18, 80, 64, 10, 63, 29, 73, 13,
        52, 61, 72, 37, 66, 50, 85, 57, 81,  8, 17, 24,
        67, 22, 71,  1,  7, 56, 26, 27, 47, 39, 79, 89,
        60, 40, 16, 69,  9, 25, 32, 86, 78, 42, 41, 65,
        87, 48,  4, 94
        ];

        seeder.updateOriginalsArtMapping(artMapping);

        string[] memory inputs = new string[](3);
        inputs[0] = "yarn";
        inputs[1] = "render-image";

        uint256 amountToGenerate = 5;

        for (uint256 i = 0; i < amountToGenerate; i++) {
            token.mint(address(1), i);

            console.log("Fetching tokenURI for token ID: ", i);

            vm.writeFile(
                string(abi.encodePacked("./script/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[2] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 50; i < 50 + amountToGenerate; i++) {
            token.mint(address(1), i);

            console.log("Fetching tokenURI for token ID: ", i);

            vm.writeFile(
                string(abi.encodePacked("./script/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[2] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 100; i < 100 + amountToGenerate; i++) {
            token.mint(address(1), i);

            console.log("Fetching tokenURI for token ID: ", i);

            vm.writeFile(
                string(abi.encodePacked("./script/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[2] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 200; i < 200 + amountToGenerate; i++) {
            token.mint(address(1), i);
            vm.writeFile(
                string(abi.encodePacked("./script/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[2] = i.toString();
            vm.ffi(inputs);
        }
    }
}
