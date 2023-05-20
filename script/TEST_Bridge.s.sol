// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

contract Bridge is BaseScript {
    uint256 idToBridge = 1;
    string chainFrom = "avalanche_fuji";
    string chainTo = "bnb_smart_chain_testnet";

    function run() public {
        Deployment memory configFrom = configs[chainFrom];
        Deployment memory configTo = configs[chainTo];

        // Bridge token
        vm.createSelectFork(StdChains.getChain(chainFrom).rpcUrl);

        SmolJoes smolJoes = SmolJoes(configFrom.smolJoes);

        (uint256 nativeFee,) =
            smolJoes.estimateSendFee(configTo.chainIdLZ, abi.encodePacked(deployer), idToBridge, false, "");

        vm.startBroadcast(deployer);

        smolJoes.sendFrom{value: nativeFee}(
            deployer, configTo.chainIdLZ, abi.encodePacked(deployer), idToBridge, payable(deployer), address(0), ""
        );

        vm.stopBroadcast();
    }
}
