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
            SmolJoeSeeder seeder = SmolJoeSeeder(config.seeder);
            SmolJoeDescriptor descriptor = SmolJoeDescriptor(config.descriptor);

            vm.startBroadcast(deployer);

            smolJoes.setPendingOwner(config.multisig);
            seeder.transferOwnership(config.multisig);
            descriptor.transferOwnership(config.multisig);

            vm.stopBroadcast();
        }
    }
}
