// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract DeployContract is BaseScript {
    function run() public {
        for (uint256 i = 0; i < chains.length; i++) {
            string memory chain = chains[i];
            Deployment memory config = configs[chain];

            console.log("\n======Deploying contracts to chain: %s======\n", chain);

            vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

            vm.startBroadcast(deployer);

            Inflator inflator = new Inflator();
            SVGRenderer renderer = new SVGRenderer();
            SmolJoeSeeder seeder = new SmolJoeSeeder();


            uint256 deployerNonce = vm.getNonce(deployer);
            address artAddressPrediction = computeCreateAddress(deployer, deployerNonce + 1);

            SmolJoeDescriptor descriptor = new SmolJoeDescriptor(ISmolJoeArt(artAddressPrediction), renderer);
            SmolJoeArt art = new SmolJoeArt(address(descriptor), inflator);

            require(address(art) == artAddressPrediction, "Art address prediction failed");

            SmolJoes smolJoes = new SmolJoes(descriptor, seeder, config.lzEndpoint, deployer);

            seeder.setSmolJoesAddress(address(smolJoes));

            vm.stopBroadcast();

            console.log("SmolJoeArt: %s", address(art));
            console.log("SmolJoeDescriptor: %s", address(descriptor));
            console.log("SmolJoeSeeder: %s", address(seeder));
            console.log("SmolJoes: %s", address(smolJoes));
        }
    }
}
