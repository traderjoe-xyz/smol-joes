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
        // vm.createSelectFork(StdChains.getChain("avalanche_fuji").rpcUrl);
        // token = SmolJoes(0x2FeceDF3e697DaFCe67fdD1d5972e2E29e8C8D60);
        // descriptor = SmolJoeDescriptor(0xcB1444cE17aA1A4Cf00F436EB7Fb99fcAc88BC08);

        inflator = new Inflator();
        renderer = new SVGRenderer();
        seeder = new SmolJoeSeeder();

        descriptor = new SmolJoeDescriptor(ISmolJoeArt(address(0)), renderer);
        art = new SmolJoeArt(address(descriptor), inflator);
        descriptor.setArt(art);

        uint256 gasLeft = gasleft();
        _populateDescriptorV2();
        console.log("Gas used: ", gasLeft - gasleft());

        token = new SmolJoes(descriptor, seeder);

        uint256 tokenID = 2;

        token.mint(address(1), tokenID);
        vm.writeFile("./uri.txt", token.tokenURI(tokenID));
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

        (bytes memory pants, uint80 pantsLength, uint16 pantsCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/pantsPage.abi")), (bytes, uint80, uint16));
        descriptor.addPants(pants, pantsLength, pantsCount);

        (bytes memory shoes, uint80 shoesLength, uint16 shoesCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/shoesPage.abi")), (bytes, uint80, uint16));
        descriptor.addShoes(shoes, shoesLength, shoesCount);

        (bytes memory shirts, uint80 shirtsLength, uint16 shirtsCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/shirtsPage.abi")), (bytes, uint80, uint16));
        descriptor.addShirts(shirts, shirtsLength, shirtsCount);

        (bytes memory beards, uint80 beardsLength, uint16 beardsCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/beardsPage.abi")), (bytes, uint80, uint16));
        descriptor.addBeards(beards, beardsLength, beardsCount);

        (bytes memory heads, uint80 headsLength, uint16 headsCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/headsPage.abi")), (bytes, uint80, uint16));
        descriptor.addHeads(heads, headsLength, headsCount);

        (bytes memory eyes, uint80 eyesLength, uint16 eyesCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/eyesPage.abi")), (bytes, uint80, uint16));
        descriptor.addEyes(eyes, eyesLength, eyesCount);

        (bytes memory accessories, uint80 accessoriesLength, uint16 accessoriesCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/accessoriesPage.abi")), (bytes, uint80, uint16));
        descriptor.addAccessories(accessories, accessoriesLength, accessoriesCount);
    }
}
