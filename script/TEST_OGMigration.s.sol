// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract OGMigration is BaseScript {
    string chain = "avalanche_fuji";

    function run() public {
        Deployment memory config = configs[chain];

        vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

        SmolJoes smolJoes = SmolJoes(config.smolJoes);
        ISmolJoeDescriptor oldDescriptor = ISmolJoeDescriptor(config.descriptor);

        vm.startBroadcast(deployer);

        SmolJoeDescriptor descriptor = new SmolJoeDescriptor(ISmolJoeArt(config.art), oldDescriptor.renderer());
        oldDescriptor.setArtDescriptor(address(descriptor));
        smolJoes.setDescriptor(descriptor);

        descriptor.setOGMigrationURI("ipfs://bafybeiggzo52clc6wgbhistulakc6ty2xaut4flv2gkohfgqiradgnabzu/");
        descriptor.setOGMigrationTrigger(true);

        OriginalSmolJoes originals =
            new OriginalSmolJoes(descriptor, ISmolJoeSeeder(config.seeder), address(config.lzEndpoint), msg.sender);
        OGMigrationWorkshop migrationWorkshop =
            new OGMigrationWorkshop(address(smolJoes), address(originals), block.timestamp);
        originals.setWorkshop(address(migrationWorkshop));
        descriptor.setOriginals(address(originals));

        smolJoes.setApprovalForAll(address(migrationWorkshop), true);
        migrationWorkshop.migrate(0);

        console.log("OG Migration Workshop: ", address(migrationWorkshop));
        console.log("Original Smol Joes: ", address(originals));
        console.log("Descriptor: ", address(descriptor));

        vm.stopBroadcast();
    }
}
