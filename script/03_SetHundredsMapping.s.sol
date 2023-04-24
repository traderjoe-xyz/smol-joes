// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract SetMapping is BaseScript {
    // Mapping has been fetched using the `get-the-hundreds-mapping` task
    function run() public {
        // forgefmt: disable-next-item
        uint8[100] memory artMapping = [
        42,  2, 54, 11, 74, 68, 34, 90, 14, 52, 23, 77,
        91, 61, 88, 58, 50,  3, 48, 93, 43, 31, 35, 21,
        6, 84,  5, 70, 92, 99, 97, 98, 45, 37, 33, 12,
        95, 53, 30, 96, 76, 20, 15, 28, 63, 82, 44, 75,
        0, 83, 19, 57, 18, 80, 64, 10, 62, 29, 73, 13,
        51, 60, 72, 36, 66, 49, 85, 56, 81,  8, 17, 24,
        67, 22, 71,  1,  7, 55, 26, 27, 46, 38, 79, 89,
        59, 39, 16, 69,  9, 25, 32, 86, 78, 41, 40, 65,
        87, 47,  4, 94
        ];

        for (uint256 i = 0; i < chains.length; i++) {
            string memory chain = chains[i];

            // Only set the mapping on the base chain
            if (
                keccak256(abi.encode(chain)) == keccak256(abi.encode("anvil"))
                    || keccak256(abi.encode(chain)) == keccak256(abi.encode("avalanche_fuji"))
                    || keccak256(abi.encode(chain)) == keccak256(abi.encode("avalanche_mainnet"))
            ) {
                Deployment memory config = configs[chain];

                vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

                ISmolJoeSeeder seeder = ISmolJoeSeeder(config.seeder);

                vm.startBroadcast(deployer);

                seeder.updateOriginalsArtMapping(artMapping);

                vm.stopBroadcast();
            }
        }
    }
}
