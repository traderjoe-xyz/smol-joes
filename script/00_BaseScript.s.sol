// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "forge-std/Script.sol";

import {SmolJoes, ISmolJoes} from "src/SmolJoes.sol";
import {SmolJoeDescriptor, ISmolJoeDescriptor} from "src/SmolJoeDescriptor.sol";
import {SmolJoeSeeder, ISmolJoeSeeder} from "src/SmolJoeSeeder.sol";
import {SmolJoeWorkshop, ISmolJoeWorkshop} from "src/SmolJoeWorkshop.sol";
import {SVGRenderer} from "src/SVGRenderer.sol";
import {SmolJoeArt, ISmolJoeArt} from "src/SmolJoeArt.sol";
import {Inflator} from "src/Inflator.sol";

contract BaseScript is Script {
    using stdJson for string;

    // For local testing on anvil, use the first default private key
    // and the deployed addresses will correspond to the ones in the config.json file.
    // string[] chains = ["anvil"];

    string[] chains = ["avalanche"];

    address deployer;
    mapping(string => Deployment) configs;

    struct Deployment {
        address art;
        uint16 chainIdLZ;
        address descriptor;
        address lzEndpoint;
        address multisig;
        address seeder;
        address smolJoes;
        address workshop;
    }

    function setUp() public virtual {
        deployer = vm.rememberKey(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        string memory json = vm.readFile("script/config.json");

        for (uint256 i = 0; i < chains.length; i++) {
            string memory chain = chains[i];

            bytes memory rawDeploymentData = json.parseRaw(string(abi.encodePacked(".", chains[i])));
            configs[chain] = abi.decode(rawDeploymentData, (Deployment));
        }
    }
}
