// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract DeployWorkshop is BaseScript {
    using stdJson for string;

    string chain = "avalanche";

    address smolJoesV1 = 0xC70DF87e1d98f6A531c8E324C9BCEC6FC82B5E8d;
    address smolCreeps = 0x2cD4DbCbfC005F8096C22579585fB91097D8D259;
    address smolPumpkins = 0x62254542187211B521bc93E4AA24629Fc01a699c;
    address beegPumpkins = 0x2b1c0aAb330741FE3f71Fb5434142f1f7Bb6b462;

    function setUp() public override {
        deployer = vm.rememberKey(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        string memory json = vm.readFile("script/config.json");

        bytes memory rawDeploymentData = json.parseRaw(string(abi.encodePacked(".", chain)));
        configs[chain] = abi.decode(rawDeploymentData, (Deployment));
    }

    function run() public {
        Deployment memory config = configs[chain];

        vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

        vm.startBroadcast(deployer);

        SmolJoeWorkshop workshop =
            new SmolJoeWorkshop(smolJoesV1, config.smolJoes, smolCreeps, smolPumpkins, beegPumpkins);

        workshop.transferOwnership(config.multisig);

        vm.stopBroadcast();

        console.log("workshop address: %s", address(workshop));
    }
}
