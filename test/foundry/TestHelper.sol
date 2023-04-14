// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "forge-std/Test.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {PopulateDescriptor} from "script/PopulateDescriptor.s.sol";

import {SmolJoes} from "contracts/SmolJoes.sol";
import {SmolJoeDescriptor, ISmolJoeDescriptor} from "contracts/SmolJoeDescriptor.sol";
import {SmolJoeSeeder, ISmolJoeSeeder} from "contracts/SmolJoeSeeder.sol";
import {SVGRenderer, ISVGRenderer} from "contracts/SVGRenderer.sol";
import {SmolJoeArt, ISmolJoeArt} from "contracts/SmolJoeArt.sol";
import {Inflator, IInflator} from "contracts/Inflator.sol";

contract TestHelper is PopulateDescriptor, Test {
    SmolJoes token;
    SmolJoeSeeder seeder;
    SmolJoeDescriptor descriptor;
    SmolJoeArt art;
    SVGRenderer renderer;
    Inflator inflator;

    function setUp() public virtual {
        inflator = new Inflator();
        renderer = new SVGRenderer();
        seeder = new SmolJoeSeeder();

        descriptor = new SmolJoeDescriptor(ISmolJoeArt(address(1)), renderer);
        art = new SmolJoeArt(address(descriptor), inflator);

        uint8[100] memory artMapping;
        for (uint8 i = 0; i < artMapping.length; i++) {
            artMapping[i] = i;
        }
        seeder.updateOriginalsArtMapping(artMapping);

        token = new SmolJoes(descriptor, seeder);

        descriptor.setArt(art);
        seeder.setSmolJoesAddress(address(token));
    }
}
