// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./00_BaseScript.s.sol";

import {ERC721, Strings} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DeployWorkshopCollections is BaseScript {
    string chain = "anvil";

    function run() public {
        Deployment memory config = configs[chain];

        vm.createSelectFork(StdChains.getChain(chain).rpcUrl);

        SmolJoes smolJoes = SmolJoes(config.smolJoes);

        vm.startBroadcast(deployer);

        address smolJoesV1 = address(
            new WorkshopFakeCollection("Smol Joes",75,100, "ipfs://bafybeihosc6jrek4ow4jolwgrimig4phfth7d5hgjy4xfpdba4wdy3troy/")
        );

        address smolCreeps = address(
            new WorkshopFakeCollection("Smol Creeps",562,800, "ipfs://bafybeib7okszfcmr57izgmtshc5lzmth5jggs5mhtykm7frlejfekdvabm/")
        );

        address beegPumpkins = address(
            new WorkshopFakeCollection("Beeg Pumpkins",0,100, "ipfs://bafybeidwjctvyr2xwy2if66b6rig5ho22at5atxg6cgmxmb65qx75n3g5m/")
        );

        address smolPumpkins = address(
            new WorkshopFakeCollection("Smol Pumpkins",0,700, "ipfs://bafybeiapzmwqondqlzm2mo45kb7zu3w36wthbr6iee2h72bu3kflny3imm/")
        );

        SmolJoeWorkshop workshop = new SmolJoeWorkshop(
            smolJoesV1,
            address(smolJoes),
            smolCreeps,
            beegPumpkins,
            smolPumpkins
        );

        workshop.setGlobalEndTime(uint64(block.timestamp + 100 days));
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.SmolJoe, block.timestamp);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.UniqueCreep, block.timestamp);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.GenerativeCreep, block.timestamp);
        workshop.setUpgradeStartTime(ISmolJoeWorkshop.StartTimes.NoPumpkins, block.timestamp);

        smolJoes.setWorkshop(address(workshop));

        vm.stopBroadcast();

        console.log("Smol Joes V1: ", smolJoesV1);
        console.log("Smol Creeps: ", smolCreeps);
        console.log("Beeg Pumpkins: ", beegPumpkins);
        console.log("Smol Pumpkins: ", smolPumpkins);

        WorkshopFakeCollection(smolJoesV1).mint(0);
        WorkshopFakeCollection(smolJoesV1).approve(address(workshop), 0);
        workshop.upgradeSmolJoe{value: 5 ether}(0);
    }
}

contract WorkshopFakeCollection is ERC721 {
    using Strings for uint256;

    uint256 private _batchRevealOffset;
    uint256 private _collectionSize;
    string private _uri;

    constructor(string memory collectionName, uint256 batchRevealOffset, uint256 collectionSize, string memory uri)
        ERC721(collectionName, "WFC")
    {
        _batchRevealOffset = batchRevealOffset;
        _collectionSize = collectionSize;
        _uri = uri;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        uint256 imageId = (tokenId + _batchRevealOffset) % _collectionSize;
        return string(abi.encodePacked(_uri, imageId.toString()));
    }

    function mint(uint256 tokenId) public {
        require(tokenId < _collectionSize, "Token ID out of range");

        _mint(msg.sender, tokenId);
    }
}
