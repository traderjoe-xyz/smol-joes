// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract Mint is BaseScript {
    string chain = "avalanche_fuji";

    uint256[] idsToMint = [0, 1, 2];

    function run() public {
        Deployment memory config = configs[chain];

        vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

        SmolJoes smolJoes = SmolJoes(config.smolJoes);

        vm.startBroadcast(deployer);

        if (smolJoes.workshop() != deployer) {
            smolJoes.setWorkshop(deployer);
        }

        for (uint256 i = 0; i < idsToMint.length; i++) {
            smolJoes.mint(deployer, idsToMint[i]);
        }

        vm.stopBroadcast();
    }
}
