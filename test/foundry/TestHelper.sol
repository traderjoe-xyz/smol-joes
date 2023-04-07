// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import "forge-std/Test.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {SmolJoes} from "contracts/SmolJoes.sol";
import {SmolJoeDescriptor, ISmolJoeDescriptor} from "contracts/SmolJoeDescriptor.sol";
import {SmolJoeSeeder, ISmolJoeSeeder} from "contracts/SmolJoeSeeder.sol";
import {SVGRenderer, ISVGRenderer} from "contracts/SVGRenderer.sol";
import {SmolJoeArt, ISmolJoeArt} from "contracts/SmolJoeArt.sol";
import {Inflator, IInflator} from "contracts/Inflator.sol";

contract TestHelper is Test {
    SmolJoes token;
    SmolJoeSeeder seeder;
    SmolJoeDescriptor descriptor;
    SmolJoeArt art;
    SVGRenderer renderer;
    Inflator inflator;

    /**
     * @dev Used in `_populateDescriptor()`
     */
    ISmolJoeArt.TraitType[] traitTypeList;
    ISmolJoeArt.Brotherhood[] brotherhoodList;
    bytes[] traitsList;
    uint80[] traitsLengthList;
    uint16[] traitsCountList;

    function setUp() public virtual {
        inflator = new Inflator();
        renderer = new SVGRenderer();
        seeder = new SmolJoeSeeder();

        descriptor = new SmolJoeDescriptor(ISmolJoeArt(address(1)), renderer);
        art = new SmolJoeArt(address(descriptor), inflator);
        descriptor.setArt(art);

        uint8[100] memory artMapping;
        for (uint8 i = 0; i < artMapping.length; i++) {
            artMapping[i] = i;
        }
        seeder.updateOriginalsArtMapping(artMapping);

        token = new SmolJoes(descriptor, seeder);
    }

    // created with `yarn hardhat make-descriptor-art`
    function _populateDescriptor(string memory assetsLocation, bool splitLargeTraits) internal {
        string[11] memory traitTypes = [
            "originals",
            "luminaries",
            "backgrounds",
            "bodies",
            "shoes",
            "pants",
            "shirts",
            "beards",
            "heads",
            "eyes",
            "accessories"
        ];

        string[11] memory brotherhoods = [
            "None",
            "Academics",
            "Athletes",
            "Creatives",
            "Gentlemans",
            "MagicalBeings",
            "Military",
            "Musicians",
            "Outlaws",
            "Religious",
            "Superheros"
        ];

        (bytes memory palette) =
            abi.decode(vm.parseBytes(vm.readFile(string(abi.encodePacked(assetsLocation, "palette.abi")))), (bytes));
        descriptor.setPalette(0, palette);

        for (uint256 i = 0; i < traitTypes.length; i++) {
            for (uint256 j = 0; j < brotherhoods.length; j++) {
                try vm.readFile(string(abi.encodePacked(assetsLocation, traitTypes[i], brotherhoods[j], "Page.abi")))
                returns (string memory result) {
                    (bytes memory traits, uint80 traitsLength, uint16 traitsCount) =
                        abi.decode(vm.parseBytes(result), (bytes, uint80, uint16));

                    // console.log(
                    //     "Adding %s traits for trait: %s, brotherhood: %s", traitsCount, traitTypes[i], brotherhoods[j]
                    // );

                    traitTypeList.push(ISmolJoeArt.TraitType(i));
                    brotherhoodList.push(ISmolJoeArt.Brotherhood(j));
                    traitsList.push(traits);
                    traitsLengthList.push(traitsLength);
                    traitsCountList.push(traitsCount);
                } catch {}
            }

            // console.log("Adding %s brotherhoods for trait: ", brotherhoodList.length, traitTypes[i]);

            descriptor.addMultipleTraits(traitTypeList, brotherhoodList, traitsList, traitsLengthList, traitsCountList);

            traitTypeList = new ISmolJoeArt.TraitType[](0);
            brotherhoodList = new ISmolJoeArt.Brotherhood[](0);
            traitsList = new bytes[](0);
            traitsLengthList = new uint80[](0);
            traitsCountList = new uint16[](0);
        }

        if (splitLargeTraits) {
            (bytes memory extraSpecialsTraits, uint80 extraSpecialsTraitsLength, uint16 extraSpecialsTraitsCount) = abi
                .decode(
                vm.parseBytes(vm.readFile(string(abi.encodePacked(assetsLocation, "originalsNonePage_2.abi")))),
                (bytes, uint80, uint16)
            );

            descriptor.addTraits(
                ISmolJoeArt.TraitType.Original,
                ISmolJoeArt.Brotherhood.None,
                extraSpecialsTraits,
                extraSpecialsTraitsLength,
                extraSpecialsTraitsCount
            );
        }
    }
}
