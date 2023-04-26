// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "../TestHelper.sol";

contract GenerateSVGTest is TestHelper {
    using Strings for uint256;

    function test_SVGGeneration() public {
        uint256 gasLeft = gasleft();
        _populateDescriptor(descriptor);
        console.log("Gas used to populate descriptor: ", gasLeft - gasleft());

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
            bytes memory result = vm.ffi(inputs);

            console.log(string(result));
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
