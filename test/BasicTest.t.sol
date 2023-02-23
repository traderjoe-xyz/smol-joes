// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import "forge-std/Test.sol";

import {SmolJoes} from "src/SmolJoes.sol";
import {ISmolJoeDescriptor, SmolJoeDescriptor} from "src/SmolJoeDescriptor.sol";
import {SmolJoeSeeder} from "src/SmolJoeSeeder.sol";
import {SVGRenderer} from "src/SVGRenderer.sol";
import {ISmolJoeArt, SmolJoeArt} from "src/SmolJoeArt.sol";
import {Inflator} from "src/Inflator.sol";

contract BasicTest is Test {
    SmolJoes token;
    SmolJoeSeeder seeder;
    SmolJoeDescriptor descriptor;
    SmolJoeArt art;
    SVGRenderer renderer;
    Inflator inflator;

    function setUp() public {}

    function test() public {
        // inflator = new Inflator();
        // renderer = new SVGRenderer();
        // seeder = new SmolJoeSeeder();

        // descriptor = new SmolJoeDescriptor(ISmolJoeArt(address(0)), renderer);
        // art = new SmolJoeArt(address(descriptor), inflator);
        // descriptor.setArt(art);

        // uint256 gasLeft = gasleft();
        // _populateDescriptorV2();
        // console.log("Gas used: ", gasLeft - gasleft());

        // token = new SmolJoes(descriptor, seeder);

        vm.createSelectFork(StdChains.getChain("avalanche_fuji").rpcUrl);

        token = SmolJoes(0xaB3F542aEEf0D4e3c416d784b1b841Ed9A2ba1Ab);
        uint256 tokenID = 1;

        token.mint(tokenID);
        vm.writeFile("./uri.txt", token.tokenURI(tokenID));
        // console.log(token.tokenURI(2));
    }

    function _populateDescriptorV2() internal {
        // created with `npx hardhat descriptor-art-to-console`
        (bytes memory palette, string[] memory backgrounds) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/paletteAndBackgrounds.abi")), (bytes, string[]));
        descriptor.setPalette(0, palette);
        descriptor.addManyBackgrounds(backgrounds);

        (bytes memory bodies, uint80 bodiesLength, uint16 bodiesCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/bodiesPage.abi")), (bytes, uint80, uint16));
        descriptor.addBodies(bodies, bodiesLength, bodiesCount);

        (bytes memory heads, uint80 headsLength, uint16 headsCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/headsPage.abi")), (bytes, uint80, uint16));
        descriptor.addHeads(heads, headsLength, headsCount);
    }
}
