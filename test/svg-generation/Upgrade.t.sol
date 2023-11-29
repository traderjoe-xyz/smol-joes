// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "../TestHelper.sol";

import {ISmolJoeDescriptorMinimal} from "src/interfaces/ISmolJoeDescriptorMinimal.sol";

contract Upgrade1Test is TestHelper {
    using Strings for uint256;

    function setUp() public override {
        vm.createSelectFork(StdChains.getChain("avalanche").rpcUrl, 32245298);

        inflator = Inflator(0xE4F41D953DC78653EE80e092145BdeaCC89c66e2);
        seeder = SmolJoeSeeder(0xb9e3cEBDef0A4bb58729bCe084866B60dC7629F5);
        token = SmolJoes(0xB449701A5ebB1D660CB1D206A94f151F5a544a81);

        descriptor = SmolJoeDescriptor(0x3CCBABbd7A89726465C753aeDAc8EfacF19df06C);
        art = SmolJoeArt(0x4DB994fe3716C7aA3639EB47cB1704F6278DA187);
    }

    function test_Custom_UpgradeDescriptor() public {
        ISmolJoeDescriptorMinimal previousDescriptor = token.descriptor();

        string[] memory inputs = new string[](4);
        inputs[0] = "yarn";
        inputs[1] = "render-image";

        uint256 idStart = 200;
        uint256 amountToGenerate = 120;

        for (uint256 i = idStart; i < idStart + amountToGenerate; i++) {
            console.log("Fetching tokenURI for token ID: ", i);

            // Current descriptor
            vm.prank(token.owner());
            token.setDescriptor(previousDescriptor);

            try token.tokenURI(i) returns (string memory metadata) {
                vm.writeFile(
                    string(abi.encodePacked("./script/files/raw-uris-sample/", i.toString(), ".txt")), metadata
                );

                inputs[2] = i.toString();
                inputs[3] = string(abi.encodePacked(i.toString(), "-original"));
                vm.ffi(inputs);

                // New descriptor
                vm.prank(token.owner());
                token.setDescriptor(descriptor);

                vm.writeFile(
                    string(abi.encodePacked("./script/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
                );

                inputs[2] = i.toString();
                inputs[3] = string(abi.encodePacked(i.toString(), "-update"));
                vm.ffi(inputs);
            } catch {
                console.log("Token does not exist: ", i);
            }
        }
    }
}
