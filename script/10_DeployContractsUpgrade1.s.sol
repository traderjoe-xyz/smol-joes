// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract DeployContract is BaseScript {
    function run() public {
        for (uint256 i = 0; i < chains.length; i++) {
            string memory chain = chains[i];

            console.log("\n======Deploying contracts to chain: %s======\n", chain);

            vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

            Inflator inflator = Inflator(0xE4F41D953DC78653EE80e092145BdeaCC89c66e2);

            vm.startBroadcast(deployer);

            SVGRenderer renderer = new SVGRenderer();

            uint256 deployerNonce = vm.getNonce(deployer);
            address artAddressPrediction = computeCreateAddress(deployer, deployerNonce + 1);

            SmolJoeDescriptor descriptor = new SmolJoeDescriptor(ISmolJoeArt(artAddressPrediction), renderer);
            SmolJoeArt art = new SmolJoeArt(address(descriptor), inflator);

            require(address(art) == artAddressPrediction, "Art address prediction failed");

            vm.stopBroadcast();

            console.log("SmolJoeArt: %s", address(art));
            console.log("SmolJoeDescriptor: %s", address(descriptor));
        }
    }
}
