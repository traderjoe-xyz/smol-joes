// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract AddWarriorTrait is BaseScript {
    using stdJson for string;

    string chain = "avalanche";

    function setUp() public override {
        deployer = vm.rememberKey(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        string memory json = vm.readFile("script/config.json");

        bytes memory rawDeploymentData = json.parseRaw(string(abi.encodePacked(".", chain)));
        configs[chain] = abi.decode(rawDeploymentData, (Deployment));
    }

    function run() public {
        Deployment memory config = configs[chain];

        SmolJoeDescriptor oldDescriptor = SmolJoeDescriptor(config.descriptor);
        SmolJoes smolJoesV2 = SmolJoes(config.smolJoes);
        SmolJoeArt art = SmolJoeArt(config.art);

        vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

        vm.startBroadcast(deployer);
        SmolJoeDescriptor descriptor =
            new SmolJoeDescriptor(art, oldDescriptor.renderer(), ISmolJoeDescriptor(address(0)));

        // To do from multisig
        bytes memory tx1 = abi.encodeWithSelector(SmolJoeDescriptor.setArtDescriptor.selector, address(descriptor));
        console.log("Tx 1 to : %s", address(oldDescriptor));
        console.logBytes(tx1);

        bytes memory tx2 = abi.encodeWithSelector(SmolJoes.setDescriptor.selector, address(descriptor));
        console.log("Tx 2 to : %s", address(smolJoesV2));
        console.logBytes(tx2);

        (address royaltiesReceiver,) = smolJoesV2.royaltyInfo(0, 0);

        OriginalSmolJoes originals =
            new OriginalSmolJoes(descriptor, smolJoesV2.seeder(), address(smolJoesV2.lzEndpoint()), royaltiesReceiver);
        OGMigrationWorkshop migrationWorkshop =
            new OGMigrationWorkshop(address(smolJoesV2), address(originals), block.timestamp + 365 days);
        originals.setWorkshop(address(migrationWorkshop));
        descriptor.setOriginals(address(originals));

        originals.setPendingOwner(config.multisig);
        migrationWorkshop.transferOwnership(config.multisig);
        descriptor.transferOwnership(config.multisig);

        console.log("Originals Smol Joes: %s", address(originals));
        console.log("OG Migration Workshop: %s", address(migrationWorkshop));
        console.log("Descriptor: %s", address(descriptor));
    }
}
