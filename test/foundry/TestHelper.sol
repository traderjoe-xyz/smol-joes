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

        descriptor = new SmolJoeDescriptor(ISmolJoeArt(address(0)), renderer);
        art = new SmolJoeArt(address(descriptor), inflator);
        descriptor.setArt(art);

        uint8[100] memory artMapping;
        for (uint8 i = 0; i < artMapping.length; i++) {
            artMapping[i] = i;
        }
        seeder.updateSpecialsArtMapping(artMapping);

        token = new SmolJoes(descriptor, seeder);
    }

    // created with `yarn hardhat make-descriptor-art`
    function _populateDescriptor() internal {
        string[11] memory traitTypes = [
            "specials",
            "uniques",
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
            abi.decode(vm.parseBytes(vm.readFile("./test/files/encoded-assets/palette.abi")), (bytes));
        descriptor.setPalette(0, palette);

        for (uint256 i = 0; i < traitTypes.length; i++) {
            for (uint256 j = 0; j < brotherhoods.length; j++) {
                try vm.readFile(
                    string(abi.encodePacked("./test/files/encoded-assets/", traitTypes[i], brotherhoods[j], "Page.abi"))
                ) returns (string memory result) {
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
    }
}
