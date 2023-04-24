// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract TransferOwnerships is BaseScript {
    function run() public {
        for (uint256 i = 0; i < chains.length; i++) {
            string memory chain = chains[i];
            Deployment memory config = configs[chain];

            vm.createSelectFork(StdChains.getChain(chain).rpcUrl);
            SmolJoes smolJoes = SmolJoes(config.smolJoes);

            vm.startBroadcast(deployer);
            for (uint256 j = 0; j < chains.length; j++) {
                if (i == j) continue;

                string memory chain_B = chains[j];
                Deployment memory config_B = configs[chain_B];

                smolJoes.setTrustedRemote(config_B.chainIdLZ, abi.encodePacked(config_B.smolJoes, config.smolJoes));
            }

            vm.stopBroadcast();
        }
    }
}
