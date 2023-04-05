// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "../TestHelper.sol";

contract BasicTest is TestHelper {
    using Strings for uint256;

    function test_SVGGeneration() public {
        uint256 gasLeft = gasleft();
        _populateDescriptor();
        console.log("Gas used to populate descriptor: ", gasLeft - gasleft());

        string[] memory inputs = new string[](5);
        inputs[0] = "yarn";
        inputs[1] = "hardhat";
        inputs[2] = "render-images";
        inputs[3] = "--token-id";

        for (uint256 i = 0; i < 3; i++) {
            token.mint(address(1), i);

            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 100; i < 105; i++) {
            token.mint(address(1), i);
            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }

        for (uint256 i = 200; i < 205; i++) {
            token.mint(address(1), i);
            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }
    }
}
