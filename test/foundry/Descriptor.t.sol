// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./TestHelper.sol";

contract DescriptorTest is TestHelper {
    function test_Populate() public {
        _populateDescriptor("./test/files/encoded-test-assets/", false);

        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Background, ISmolJoeArt.Brotherhood.None), 3, "test_Populate::1"
        );
        assertEq(descriptor.traitCount(ISmolJoeArt.TraitType.Body, ISmolJoeArt.Brotherhood.None), 2, "test_Populate::2");
        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Shoes, ISmolJoeArt.Brotherhood.None), 3, "test_Populate::3"
        );
        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Pants, ISmolJoeArt.Brotherhood.None), 3, "test_Populate::4"
        );
        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Shirt, ISmolJoeArt.Brotherhood.None), 3, "test_Populate::5"
        );
        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.HairCapHead, ISmolJoeArt.Brotherhood.None),
            3,
            "test_Populate::6"
        );
        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.EyeAccessory, ISmolJoeArt.Brotherhood.None),
            3,
            "test_Populate::7"
        );
        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Accessories, ISmolJoeArt.Brotherhood.None),
            3,
            "test_Populate::8"
        );

        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Original, ISmolJoeArt.Brotherhood.None), 2, "test_Populate::9"
        );

        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Luminary, ISmolJoeArt.Brotherhood.Academics),
            1,
            "test_Populate::10"
        );
    }

    function test_SetRenderer(address newRenderer, address caller) public {
        vm.assume(newRenderer != address(0) && caller != address(this));

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(caller);
        descriptor.setRenderer(ISVGRenderer(newRenderer));

        descriptor.setRenderer(ISVGRenderer(newRenderer));
        assertEq(address(descriptor.renderer()), newRenderer, "test_SetRenderer::1");
    }

    function test_SetArt(address newArt, address caller) public {
        vm.assume(newArt != address(0) && caller != address(this));

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(caller);
        descriptor.setArt(ISmolJoeArt(newArt));

        descriptor.setArt(ISmolJoeArt(newArt));
        assertEq(address(descriptor.art()), newArt, "test_SetArt::1");
    }

    function test_SetArtDescriptor(address newDescriptor, address caller) public {
        vm.assume(newDescriptor != address(0) && caller != address(this));

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(caller);
        descriptor.setArtDescriptor(newDescriptor);

        descriptor.setArtDescriptor(newDescriptor);
        assertEq(art.descriptor(), newDescriptor, "test_SetArtDescriptor::1");
    }

    function test_SetArtInflator(address newInflator, address caller) public {
        vm.assume(newInflator != address(0) && caller != address(this));

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(caller);
        descriptor.setArtInflator(IInflator(newInflator));

        descriptor.setArtInflator(IInflator(newInflator));
        assertEq(address(art.inflator()), newInflator, "test_SetArtInflator::1");
    }

    function test_SetDataURIEnabled(address caller) public {
        vm.assume(caller != address(this));

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(caller);
        descriptor.setDataURIEnabled(false);

        descriptor.setDataURIEnabled(false);
        assertEq(descriptor.isDataURIEnabled(), false, "test_SetDataURIEnabled::1");

        vm.expectRevert(ISmolJoeDescriptor.SmolJoeDescriptor__UpdateToSameState.selector);
        descriptor.setDataURIEnabled(false);

        descriptor.setDataURIEnabled(true);
        assertEq(descriptor.isDataURIEnabled(), true, "test_SetDataURIEnabled::2");
    }

    function test_TokenURIWhenDataURIDisabled() public {
        descriptor.setDataURIEnabled(false);
        descriptor.setBaseURI("https://smoljoe.com/");

        ISmolJoeSeeder.Seed memory seed;

        assertEq(descriptor.tokenURI(1, seed), "https://smoljoe.com/1", "test_TokenURIWhenDataURIDisabled::1");
    }
}
