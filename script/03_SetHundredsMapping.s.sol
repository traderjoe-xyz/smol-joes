// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract SetMapping is BaseScript {
    // Mapping has been fetched using the `get-the-hundreds-mapping` task
    function run() public {
        // forgefmt: disable-next-item
        uint8[100] memory artMapping = [
        43,  2, 55, 11, 74, 68, 34, 90, 14, 53, 23, 77,
        91, 62, 88, 59, 51,  3, 49, 93, 44, 31, 36, 21,
        6, 84,  5, 70, 92, 99, 97, 98, 46, 38, 33, 12,
        95, 54, 30, 96, 76, 20, 15, 28, 35, 82, 45, 75,
        0, 83, 19, 58, 18, 80, 64, 10, 63, 29, 73, 13,
        52, 61, 72, 37, 66, 50, 85, 57, 81,  8, 17, 24,
        67, 22, 71,  1,  7, 56, 26, 27, 47, 39, 79, 89,
        60, 40, 16, 69,  9, 25, 32, 86, 78, 42, 41, 65,
        87, 48,  4, 94
        ];

        for (uint256 i = 0; i < chains.length; i++) {
            string memory chain = chains[i];

            // Only set the mapping on the base chain
            if (
                keccak256(abi.encode(chain)) == keccak256(abi.encode("anvil"))
                    || keccak256(abi.encode(chain)) == keccak256(abi.encode("avalanche_fuji"))
                    || keccak256(abi.encode(chain)) == keccak256(abi.encode("avalanche"))
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
