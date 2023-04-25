// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "forge-std/Script.sol";

import {SmolJoes, ISmolJoes} from "contracts/SmolJoes.sol";
import {SmolJoeDescriptor, ISmolJoeDescriptor} from "contracts/SmolJoeDescriptor.sol";
import {SmolJoeSeeder, ISmolJoeSeeder} from "contracts/SmolJoeSeeder.sol";
import {SmolJoesWorkshop} from "contracts/SmolJoesWorkshop.sol";
import {SVGRenderer} from "contracts/SVGRenderer.sol";
import {SmolJoeArt, ISmolJoeArt} from "contracts/SmolJoeArt.sol";
import {Inflator} from "contracts/Inflator.sol";

contract BaseScript is Script {
    using stdJson for string;

    // For local testing on anvil, use the first default private key
    // and the deployed addresses will correspond to the ones in the config.json file.
    // string[] chains = ["anvil"];

    string[] chains = ["avalanche_fuji"];

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
