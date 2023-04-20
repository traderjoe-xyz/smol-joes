// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "forge-std/Script.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {ISmolJoeDescriptor} from "contracts/SmolJoeDescriptor.sol";
import {ISmolJoeArt} from "contracts/SmolJoeArt.sol";

contract PopulateDescriptor is Script {
    using Strings for uint256;

    /**
     * @dev Used in `_populateDescriptor()`
     */
    ISmolJoeArt.TraitType[] traitTypeList;
    ISmolJoeArt.Brotherhood[] brotherhoodList;
    bytes[] traitsList;
    uint80[] traitsLengthList;
    uint16[] traitsCountList;

    // @todo Implement script
    function run() public {}

    // created with `yarn hardhat make-descriptor-art`
    function _populateDescriptor(ISmolJoeDescriptor descriptor) internal {
        string memory assetsLocation = "script/files/encoded-assets/";

        string[10] memory traitTypes = [
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

        string[10] memory brotherhoods = [
            "academics",
            "athletes",
            "creatives",
            "gentlemen",
            "heroes",
            "magic",
            "musicians",
            "outlaws",
            "warriors",
            "worship"
        ];

        // Hundreds palette 1
        bytes memory palette = abi.decode(
            vm.parseBytes(vm.readFile(string(abi.encodePacked(assetsLocation, "hundreds_palette_1.abi")))), (bytes)
        );
        descriptor.setPalette(0, palette);

        // Hundreds palette 2
        palette = abi.decode(
            vm.parseBytes(vm.readFile(string(abi.encodePacked(assetsLocation, "hundreds_palette_2.abi")))), (bytes)
        );
        descriptor.setPalette(1, palette);

        // Palette for the rest of the assets
        palette = abi.decode(
            vm.parseBytes(vm.readFile(string(abi.encodePacked(assetsLocation, "luminaries_palette.abi")))), (bytes)
        );
        descriptor.setPalette(2, palette);

        // Images for the Hundreds are split into 6 pages
        for (uint256 i = 0; i < 6; i++) {
            try vm.readFile(string(abi.encodePacked(assetsLocation, "hundreds_page_", i.toString(), ".abi"))) returns (
                string memory result
            ) {
                (bytes memory traits, uint80 traitsLength, uint16 traitsCount) =
                    abi.decode(vm.parseBytes(result), (bytes, uint80, uint16));

                // console.log("Adding %s traits for the Hundreds", traitsCount);

                traitTypeList.push(ISmolJoeArt.TraitType.Original);
                brotherhoodList.push(ISmolJoeArt.Brotherhood.None);
                traitsList.push(traits);
                traitsLengthList.push(traitsLength);
                traitsCountList.push(traitsCount);
            } catch {
                console.log("Missing page %s for the Hundreds", i);
            }
        }

        descriptor.addMultipleTraits(traitTypeList, brotherhoodList, traitsList, traitsLengthList, traitsCountList);

        // Add traits for the Luminaries and the Smols
        for (uint256 i = 0; i < traitTypes.length; i++) {
            for (uint256 j = 0; j < brotherhoods.length; j++) {
                try vm.readFile(
                    string(abi.encodePacked(assetsLocation, traitTypes[i], "_", brotherhoods[j], "_page.abi"))
                ) returns (string memory result) {
                    (bytes memory traits, uint80 traitsLength, uint16 traitsCount) =
                        abi.decode(vm.parseBytes(result), (bytes, uint80, uint16));

                    // console.log(
                    //     "Adding %s traits for trait: %s, brotherhood: %s", traitsCount, traitTypes[i], brotherhoods[j]
                    // );

                    traitTypeList.push(ISmolJoeArt.TraitType(i + 1));
                    brotherhoodList.push(ISmolJoeArt.Brotherhood(j + 1));
                    traitsList.push(traits);
                    traitsLengthList.push(traitsLength);
                    traitsCountList.push(traitsCount);
                } catch {
                    console.log("No traits for trait: %s, brotherhood: %s", traitTypes[i], brotherhoods[j]);
                }
            }

            // console.log("Adding %s brotherhoods for trait: ", brotherhoodList.length, traitTypes[i]);

            descriptor.addMultipleTraits(traitTypeList, brotherhoodList, traitsList, traitsLengthList, traitsCountList);

            traitTypeList = new ISmolJoeArt.TraitType[](0);
            brotherhoodList = new ISmolJoeArt.Brotherhood[](0);
            traitsList = new bytes[](0);
            traitsLengthList = new uint80[](0);
            traitsCountList = new uint16[](0);
        }

        // Add emblems
        for (uint256 i = 0; i < brotherhoods.length; i++) {
            string memory emblem =
                vm.readFile(string(abi.encodePacked(assetsLocation, "emblem_", brotherhoods[i], ".abi")));

            descriptor.setHouseEmblem(ISmolJoeArt.Brotherhood(i + 1), emblem);
        }
    }
}
