// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./TestHelper.sol";

contract MultichainTest is TestHelper {
    SmolJoes token_B;
    LZEndpointMock lzEndpointMock_B;
    uint16 chainId_A = 1;
    uint16 chainId_B = 2;

    function setUp() public override {
        super.setUp();
        _populateDescriptor(descriptor);

        lzEndpointMock_B = new LZEndpointMock(chainId_B);
        token_B = new SmolJoes(descriptor, seeder, address(lzEndpointMock_B), msg.sender);

        lzEndpointMock.setDestLzEndpoint(address(token_B), address(lzEndpointMock_B));
        lzEndpointMock_B.setDestLzEndpoint(address(token), address(lzEndpointMock));

        token.setTrustedRemote(chainId_B, abi.encodePacked(address(token_B), address(token)));
        token_B.setTrustedRemote(chainId_A, abi.encodePacked(address(token), address(token_B)));

        token_B.setWorkshop(address(this));

        vm.deal(address(lzEndpointMock), 10 ether);
        vm.deal(address(lzEndpointMock_B), 10 ether);
    }

    function test_Bridge() public {
        uint256 tokenId = 200;

        token.mint(address(this), tokenId);

        assertEq(token.ownerOf(tokenId), address(this), "test_Bridge::1");

        ISmolJoeSeeder.Seed memory seed_A = token.getTokenSeed(tokenId);

        (uint256 nativeFee,) = token_B.estimateSendFee(chainId_B, abi.encodePacked(address(this)), tokenId, false, "");

        token.sendFrom{value: nativeFee}(
            address(this), chainId_B, abi.encodePacked(address(this)), tokenId, payable(address(this)), address(0), ""
        );

        assertEq(token.ownerOf(tokenId), address(token), "test_Bridge::2");
        assertEq(token_B.ownerOf(tokenId), address(this), "test_Bridge::3");

        ISmolJoeSeeder.Seed memory seed_B = token_B.getTokenSeed(tokenId);

        assertEq(abi.encode(seed_A), abi.encode(seed_B), "test_Bridge::4");
        assertEq(token.tokenURI(tokenId), token_B.tokenURI(tokenId), "test_Bridge::5");
    }

    receive() external payable {}
}
