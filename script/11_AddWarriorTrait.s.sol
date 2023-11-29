// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract AddWarriorTrait is BaseScript {
    using stdJson for string;

    string chain = "avalanche";

    string assetsLocation = "script/files/encoded-assets/";

    function setUp() public override {
        deployer = vm.rememberKey(vm.envUint("DEPLOYER_PRIVATE_KEY"));

        string memory json = vm.readFile("script/config.json");

        bytes memory rawDeploymentData = json.parseRaw(string(abi.encodePacked(".", chain)));
        configs[chain] = abi.decode(rawDeploymentData, (Deployment));
    }

    function run() public {
        Deployment memory config = configs[chain];

        vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

        bytes memory palette = abi.decode(
            vm.parseBytes(vm.readFile(string(abi.encodePacked(assetsLocation, "extra_warrior_accessory_palette.abi")))),
            (bytes)
        );

        console.log("Descriptor address: %s", config.descriptor);

        bytes memory txn = abi.encodeWithSelector(ISmolJoeDescriptor.setPalette.selector, 3, palette);
        console.logBytes(txn);

        bytes memory warriorExtraTrait =
            vm.parseBytes(vm.readFile(string(abi.encodePacked(assetsLocation, "extra_warrior_accessory_page.abi"))));

        (bytes memory extraTraits, uint80 extraTraitsLength, uint16 extraTraitsCount) =
            abi.decode(warriorExtraTrait, (bytes, uint80, uint16));

        txn = abi.encodeWithSelector(
            ISmolJoeDescriptor.addTraits.selector,
            ISmolJoeArt.TraitType.Accessories,
            ISmolJoeArt.Brotherhood.Warriors,
            extraTraits,
            extraTraitsLength,
            extraTraitsCount
        );
        console.logBytes(txn);
    }
}
