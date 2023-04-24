// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract Mint is BaseScript {
    uint256 idToMint = 2;
    string chain = "avalanche_fuji";

    function run() public {
        Deployment memory config = configs[chain];

        vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

        SmolJoes smolJoes = SmolJoes(config.smolJoes);

        vm.startBroadcast(deployer);

        if (smolJoes.workshop() != deployer) {
            smolJoes.setWorkshop(deployer);
        }

        for (uint256 i = 205; i < 220; i++) {
            smolJoes.mint(deployer, i);
        }

        vm.stopBroadcast();
    }
}
