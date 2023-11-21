// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "forge-std/Test.sol";

import {Strings} from "openzeppelin/utils/Strings.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";
import {LZEndpointMock} from "lib/nft-base-contracts/lib/solidity-examples/contracts/mocks/LZEndpointMock.sol";

import {PopulateDescriptor} from "script/02_PopulateDescriptor.s.sol";

import {SmolJoeDescriptor, ISmolJoeDescriptor} from "src/SmolJoeDescriptor.sol";
import {SmolJoeWorkshop, ISmolJoeWorkshop} from "src/SmolJoeWorkshop.sol";
import {MigrationWorkshop} from "src/OriginalsWorkshop.sol";
import {OriginalSmolJoes} from "src/OriginalSmolJoes.sol";
import {SmolJoeSeeder, ISmolJoeSeeder} from "src/SmolJoeSeeder.sol";
import {SVGRenderer, ISVGRenderer} from "src/SVGRenderer.sol";
import {SmolJoeArt, ISmolJoeArt} from "src/SmolJoeArt.sol";
import {Inflator, IInflator} from "src/Inflator.sol";
import {SmolJoes} from "src/SmolJoes.sol";

contract TestHelper is PopulateDescriptor, Test {
    SmolJoes token;
    SmolJoeSeeder seeder;
    SmolJoeDescriptor descriptor;
    SmolJoeArt art;
    SVGRenderer renderer;
    Inflator inflator;

    LZEndpointMock lzEndpointMock;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public virtual override {
        inflator = new Inflator();
        renderer = new SVGRenderer();
        seeder = new SmolJoeSeeder();

        lzEndpointMock = new LZEndpointMock(1);

        descriptor = new SmolJoeDescriptor(ISmolJoeArt(address(1)), renderer);
        art = new SmolJoeArt(address(descriptor), inflator);

        uint8[100] memory artMapping;
        for (uint8 i = 0; i < artMapping.length; i++) {
            artMapping[i] = i;
        }
        seeder.updateOriginalsArtMapping(artMapping);

        token = new SmolJoes(descriptor, seeder, address(lzEndpointMock), msg.sender);

        descriptor.setArt(art);
        seeder.setSmolJoesAddress(address(token));

        token.setWorkshop(address(this));
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}
