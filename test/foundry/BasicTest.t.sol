// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import "forge-std/Test.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {SmolJoes} from "contracts/SmolJoes.sol";
import {ISmolJoeDescriptor, SmolJoeDescriptor} from "contracts/SmolJoeDescriptor.sol";
import {SmolJoeSeeder} from "contracts/SmolJoeSeeder.sol";
import {SVGRenderer} from "contracts/SVGRenderer.sol";
import {ISmolJoeArt, SmolJoeArt} from "contracts/SmolJoeArt.sol";
import {ISmolJoeSeeder} from "contracts/interfaces/ISmolJoeSeeder.sol";
import {Inflator} from "contracts/Inflator.sol";

contract BasicTest is Test {
    using Strings for uint256;

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

        // art.addEmptyItems("");

        uint256 gasLeft = gasleft();
        _populateDescriptorV2();
        console.log("Gas used: ", gasLeft - gasleft());

        token = new SmolJoes(descriptor, seeder);

        string[] memory inputs = new string[](5);
        inputs[0] = "yarn";
        inputs[1] = "hardhat";
        inputs[2] = "render-images";
        inputs[3] = "--token-id";

        for (uint256 i = 0; i < 10; i++) {
            if (i < 2) {
                token.mintSpecial(address(1), i, ISmolJoeSeeder.SmolJoeCast.Special);
            } else {
                token.mint(address(1), i);
            }
            vm.writeFile(
                string(abi.encodePacked("./test/files/raw-uris-sample/", i.toString(), ".txt")), token.tokenURI(i)
            );

            inputs[4] = i.toString();
            vm.ffi(inputs);
        }
    }

    function _populateDescriptorV2() internal {
        // created with `yarn hardhat make-descriptor-art`
        (bytes memory palette) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/encoded-assets/palette.abi")), (bytes));
        descriptor.setPalette(0, palette);

        (bytes memory backgrounds, uint80 backgroundsLength, uint16 backgroundsCount) = abi.decode(
            vm.parseBytes(vm.readFile("./test/files/encoded-assets/backgroundsPage.abi")), (bytes, uint80, uint16)
        );
        descriptor.addTraits(ISmolJoeArt.TraitType.Backgrounds, backgrounds, backgroundsLength, backgroundsCount);

        (bytes memory bodies, uint80 bodiesLength, uint16 bodiesCount) = abi.decode(
            vm.parseBytes(vm.readFile("./test/files/encoded-assets/bodiesPage.abi")), (bytes, uint80, uint16)
        );
        descriptor.addTraits(ISmolJoeArt.TraitType.Bodies, bodies, bodiesLength, bodiesCount);

        (bytes memory pants, uint80 pantsLength, uint16 pantsCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/encoded-assets/pantsPage.abi")), (bytes, uint80, uint16));
        descriptor.addTraits(ISmolJoeArt.TraitType.Pants, pants, pantsLength, pantsCount);

        (bytes memory shoes, uint80 shoesLength, uint16 shoesCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/encoded-assets/shoesPage.abi")), (bytes, uint80, uint16));
        descriptor.addTraits(ISmolJoeArt.TraitType.Shoes, shoes, shoesLength, shoesCount);

        (bytes memory shirts, uint80 shirtsLength, uint16 shirtsCount) = abi.decode(
            vm.parseBytes(vm.readFile("./test/files/encoded-assets/shirtsPage.abi")), (bytes, uint80, uint16)
        );
        descriptor.addTraits(ISmolJoeArt.TraitType.Shirts, shirts, shirtsLength, shirtsCount);

        (bytes memory beards, uint80 beardsLength, uint16 beardsCount) = abi.decode(
            vm.parseBytes(vm.readFile("./test/files/encoded-assets/beardsPage.abi")), (bytes, uint80, uint16)
        );
        descriptor.addTraits(ISmolJoeArt.TraitType.Beards, beards, beardsLength, beardsCount);

        (bytes memory heads, uint80 headsLength, uint16 headsCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/encoded-assets/headsPage.abi")), (bytes, uint80, uint16));
        descriptor.addTraits(ISmolJoeArt.TraitType.Heads, heads, headsLength, headsCount);

        (bytes memory eyes, uint80 eyesLength, uint16 eyesCount) =
            abi.decode(vm.parseBytes(vm.readFile("./test/files/encoded-assets/eyesPage.abi")), (bytes, uint80, uint16));
        descriptor.addTraits(ISmolJoeArt.TraitType.Eyes, eyes, eyesLength, eyesCount);

        (bytes memory accessories, uint80 accessoriesLength, uint16 accessoriesCount) = abi.decode(
            vm.parseBytes(vm.readFile("./test/files/encoded-assets/accessoriesPage.abi")), (bytes, uint80, uint16)
        );
        descriptor.addTraits(ISmolJoeArt.TraitType.Accessories, accessories, accessoriesLength, accessoriesCount);

        (bytes memory specials, uint80 specialsLength, uint16 specialsCount) = abi.decode(
            vm.parseBytes(vm.readFile("./test/files/encoded-assets/specialsPage.abi")), (bytes, uint80, uint16)
        );
        descriptor.addTraits(ISmolJoeArt.TraitType.Special, specials, specialsLength, specialsCount);
    }
}
