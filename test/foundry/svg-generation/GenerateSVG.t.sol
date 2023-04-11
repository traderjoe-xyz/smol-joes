// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "../TestHelper.sol";

contract BasicTest is TestHelper {
    using Strings for uint256;

    function test_SVGGeneration() public {
        uint256 gasLeft = gasleft();
        _populateDescriptor("./test/files/encoded-assets/", true);
        console.log("Gas used to populate descriptor: ", gasLeft - gasleft());

        string[] memory inputs = new string[](5);
        inputs[0] = "yarn";
        inputs[1] = "hardhat";
        inputs[2] = "render-images";
        inputs[3] = "--token-id";

        uint256 amountToGenerate = 1;

        for (uint256 i = 0; i < amountToGenerate; i++) {
            token.mint(address(1), i);

            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 50; i < 50 + amountToGenerate; i++) {
            token.mint(address(1), i);

            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 100; i < 100 + amountToGenerate; i++) {
            token.mint(address(1), i);
            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 200; i < 200 + amountToGenerate; i++) {
            token.mint(address(1), i);
            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }
    }
}
