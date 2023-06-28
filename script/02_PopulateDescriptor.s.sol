// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

import {Strings} from "openzeppelin/utils/Strings.sol";

contract PopulateDescriptor is BaseScript {
    using stdJson for string;
    using Strings for uint256;

    function run() public {
        for (uint256 i = 0; i < chains.length; i++) {
            string memory chain = chains[i];
            Deployment memory config = configs[chain];

            vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

            ISmolJoeDescriptor descriptor = ISmolJoeDescriptor(config.descriptor);

            vm.startBroadcast(deployer);

            _populateDescriptor(descriptor);

            vm.stopBroadcast();
        }
    }

    // Data used here is created with `yarn make-art`
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

                descriptor.addTraits(
                    ISmolJoeArt.TraitType.Original, ISmolJoeArt.Brotherhood.None, traits, traitsLength, traitsCount
                );
            } catch {
                console.log("Missing page %s for the Hundreds", i);
            }
        }

        // Add traits for the Luminaries, in two batches
        uint256 batchSize = 5;

        ISmolJoeArt.TraitType[] memory traitTypeList = new ISmolJoeArt.TraitType[](batchSize);
        ISmolJoeArt.Brotherhood[] memory brotherhoodList = new ISmolJoeArt.Brotherhood[](batchSize);
        bytes[] memory traitsList = new bytes[](batchSize);
        uint80[] memory traitsLengthList = new uint80[](batchSize);
        uint16[] memory traitsCountList = new uint16[](batchSize);

        for (uint256 i = 0; i < brotherhoods.length / batchSize; i++) {
            for (uint256 j = 0; j < batchSize; j++) {
                try vm.readFile(
                    string(
                        abi.encodePacked(
                            assetsLocation, traitTypes[0], "_", brotherhoods[j + i * batchSize], "_page.abi"
                        )
                    )
                ) returns (string memory result) {
                    (bytes memory traits, uint80 traitsLength, uint16 traitsCount) =
                        abi.decode(vm.parseBytes(result), (bytes, uint80, uint16));

                    traitTypeList[j] = ISmolJoeArt.TraitType.Luminary;
                    brotherhoodList[j] = ISmolJoeArt.Brotherhood(j + i * batchSize + 1);
                    traitsList[j] = traits;
                    traitsLengthList[j] = traitsLength;
                    traitsCountList[j] = traitsCount;
                } catch {
                    console.log(
                        "No traits for trait: %s, brotherhood: %s, page: %s",
                        traitTypes[0],
                        brotherhoods[j + i * batchSize],
                        i
                    );
                }
            }

            // console.log("Adding %s brotherhoods for trait: ", brotherhoodList.length, traitTypes[0]);

            descriptor.addMultipleTraits(traitTypeList, brotherhoodList, traitsList, traitsLengthList, traitsCountList);
        }

        // Add traits for  the Smols
        traitTypeList = new ISmolJoeArt.TraitType[](brotherhoods.length);
        brotherhoodList = new ISmolJoeArt.Brotherhood[](brotherhoods.length);
        traitsList = new bytes[](brotherhoods.length);
        traitsLengthList = new uint80[](brotherhoods.length);
        traitsCountList = new uint16[](brotherhoods.length);

        for (uint256 i = 1; i < traitTypes.length; i++) {
            for (uint256 j = 0; j < brotherhoods.length; j++) {
                try vm.readFile(
                    string(abi.encodePacked(assetsLocation, traitTypes[i], "_", brotherhoods[j], "_page.abi"))
                ) returns (string memory result) {
                    (bytes memory traits, uint80 traitsLength, uint16 traitsCount) =
                        abi.decode(vm.parseBytes(result), (bytes, uint80, uint16));

                    traitTypeList[j] = ISmolJoeArt.TraitType(i + 1);
                    brotherhoodList[j] = ISmolJoeArt.Brotherhood(j + 1);
                    traitsList[j] = traits;
                    traitsLengthList[j] = traitsLength;
                    traitsCountList[j] = traitsCount;
                } catch {
                    console.log("No traits for trait: %s, brotherhood: %s", traitTypes[i], brotherhoods[j]);
                }
            }

            // console.log("Adding %s brotherhoods for trait: ", brotherhoodList.length, traitTypes[i]);

            descriptor.addMultipleTraits(traitTypeList, brotherhoodList, traitsList, traitsLengthList, traitsCountList);
        }

        // Add emblems
        for (uint256 i = 0; i < brotherhoods.length; i++) {
            string memory emblem =
                vm.readFile(string(abi.encodePacked(assetsLocation, "emblem_", brotherhoods[i], ".abi")));

            descriptor.setHouseEmblem(ISmolJoeArt.Brotherhood(i + 1), emblem);
        }

        // Add glowing emblems
        for (uint256 i = 0; i < brotherhoods.length; i++) {
            string memory emblem =
                vm.readFile(string(abi.encodePacked(assetsLocation, "glowing_emblem_", brotherhoods[i], ".abi")));

            descriptor.setGlowingHouseEmblem(ISmolJoeArt.Brotherhood(i + 1), emblem);
        }

        // Add Luminaries metadata
        for (uint256 i = 0; i < brotherhoods.length; i++) {
            bytes memory metadata = vm.parseBytes(
                vm.readFile(string(abi.encodePacked(assetsLocation, "metadata_", brotherhoods[i], ".abi")))
            );

            descriptor.setLuminariesMetadata(ISmolJoeArt.Brotherhood(i + 1), metadata);
        }
    }
}
