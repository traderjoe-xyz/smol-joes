// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract Bridge is BaseScript {
    uint256 idToBridge = 200;
    string chainFrom = "anvil";
    string chainTo = "anvil_2";

    function run() public {
        Deployment memory configFrom = configs[chainFrom];
        Deployment memory configTo = configs[chainTo];

        // Estimate fees on destination chain
        vm.createSelectFork(StdChains.getChain(chainTo).rpcUrl);
        SmolJoes smolJoes = SmolJoes(configTo.smolJoes);
        (uint256 nativeFee,) =
            smolJoes.estimateSendFee(configTo.chainIdLZ, abi.encodePacked(deployer), idToBridge, false, "");

        // Bridge token
        vm.createSelectFork(StdChains.getChain(chainFrom).rpcUrl);

        smolJoes = SmolJoes(configFrom.smolJoes);

        vm.startBroadcast(deployer);

        smolJoes.sendFrom{value: nativeFee}(
            address(this), configTo.chainIdLZ, abi.encodePacked(deployer), idToBridge, payable(deployer), address(0), ""
        );

        vm.stopBroadcast();
    }
}
