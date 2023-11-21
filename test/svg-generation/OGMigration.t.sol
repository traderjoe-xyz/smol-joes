// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "../TestHelper.sol";

import {ISmolJoeDescriptorMinimal} from "src/interfaces/ISmolJoeDescriptorMinimal.sol";

contract OGMigrationTest is TestHelper {
    using Strings for uint256;

    SmolJoeDescriptor oldDescriptor;

    uint256 constant OG_INDEX = 0;
    uint256 constant LUMINARY_INDEX = 101;
    uint256 constant GENERATIVE_INDEX = 202;

    function setUp() public override {
        vm.createSelectFork(StdChains.getChain("avalanche").rpcUrl, 37715644);

        inflator = Inflator(0xE4F41D953DC78653EE80e092145BdeaCC89c66e2);
        seeder = SmolJoeSeeder(0xb9e3cEBDef0A4bb58729bCe084866B60dC7629F5);
        token = SmolJoes(0xB449701A5ebB1D660CB1D206A94f151F5a544a81);

        oldDescriptor = SmolJoeDescriptor(0x3CCBABbd7A89726465C753aeDAc8EfacF19df06C);
        art = SmolJoeArt(0x4DB994fe3716C7aA3639EB47cB1704F6278DA187);
    }

    function test_Custom_MigrateOGs() public {
        bytes32 ogURIHash = keccak256(abi.encodePacked(token.tokenURI(OG_INDEX)));
        bytes32 luminaryURIHash = keccak256(abi.encodePacked(token.tokenURI(LUMINARY_INDEX)));
        bytes32 generativeURIHash = keccak256(abi.encodePacked(token.tokenURI(GENERATIVE_INDEX)));

        vm.startPrank(token.owner());
        descriptor = new SmolJoeDescriptor(art, oldDescriptor.renderer());
        oldDescriptor.setArtDescriptor(address(descriptor));
        token.setDescriptor(descriptor);

        assertEq(keccak256(abi.encodePacked(token.tokenURI(OG_INDEX))), ogURIHash, "test_Custom_MigrateOGs::0");
        assertEq(
            keccak256(abi.encodePacked(token.tokenURI(LUMINARY_INDEX))), luminaryURIHash, "test_Custom_MigrateOGs::1"
        );
        assertEq(
            keccak256(abi.encodePacked(token.tokenURI(GENERATIVE_INDEX))),
            generativeURIHash,
            "test_Custom_MigrateOGs::2"
        );

        descriptor.setOGMigrationTrigger(true);
        assertEq(token.tokenURI(OG_INDEX), OG_INDEX.toString(), "test_Custom_MigrateOGs::3");
        assertEq(
            keccak256(abi.encodePacked(token.tokenURI(LUMINARY_INDEX))), luminaryURIHash, "test_Custom_MigrateOGs::4"
        );
        assertEq(
            keccak256(abi.encodePacked(token.tokenURI(GENERATIVE_INDEX))),
            generativeURIHash,
            "test_Custom_MigrateOGs::5"
        );
    }
}
