// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import "./TestHelper.sol";

contract DescriptorTest is TestHelper {
    uint256[10] private _backgroundsByBrotherhood = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    uint256[10] private _bodiesByBrotherhood = [1, 3, 2, 3, 2, 4, 2, 2, 2, 3];
    uint256[10] private _shoesByBrotherhood = [6, 8, 6, 4, 5, 8, 3, 6, 7, 5];
    uint256[10] private _pantsByBrotherhood = [5, 10, 8, 7, 9, 10, 7, 7, 6, 7];
    uint256[10] private _shirtsByBrotherhood = [10, 8, 9, 9, 9, 8, 10, 10, 9, 9];
    uint256[10] private _beardsByBrotherhood = [5, 5, 5, 5, 5, 5, 4, 4, 5, 3];
    uint256[10] private _hairsCapsHeadsByBrotherhood = [9, 9, 10, 8, 9, 10, 8, 10, 8, 10];
    uint256[10] private _eyeAccessoriesByBrotherhood = [3, 3, 3, 5, 2, 2, 5, 2, 1, 3];
    uint256[10] private _accessoriesByBrotherhood = [7, 10, 8, 7, 8, 8, 5, 7, 6, 8];

    function test_Populate() public {
        _populateDescriptor(descriptor);

        for (uint256 i = 0; i < 10; i++) {
            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.Background, ISmolJoeArt.Brotherhood(i + 1)),
                _backgroundsByBrotherhood[i],
                "test_Populate::1"
            );

            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.Body, ISmolJoeArt.Brotherhood(i + 1)),
                _bodiesByBrotherhood[i],
                "test_Populate::2"
            );

            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.Shoes, ISmolJoeArt.Brotherhood(i + 1)),
                _shoesByBrotherhood[i],
                "test_Populate::3"
            );

            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.Pants, ISmolJoeArt.Brotherhood(i + 1)),
                _pantsByBrotherhood[i],
                "test_Populate::4"
            );

            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.Shirt, ISmolJoeArt.Brotherhood(i + 1)),
                _shirtsByBrotherhood[i],
                "test_Populate::5"
            );
            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.HairCapHead, ISmolJoeArt.Brotherhood(i + 1)),
                _hairsCapsHeadsByBrotherhood[i],
                "test_Populate::6"
            );
            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.EyeAccessory, ISmolJoeArt.Brotherhood(i + 1)),
                _eyeAccessoriesByBrotherhood[i],
                "test_Populate::7"
            );
            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.Accessories, ISmolJoeArt.Brotherhood(i + 1)),
                _accessoriesByBrotherhood[i],
                "test_Populate::8"
            );

            assertEq(
                descriptor.traitCount(ISmolJoeArt.TraitType.Luminary, ISmolJoeArt.Brotherhood.Academics),
                10,
                "test_Populate::9"
            );
        }

        assertEq(
            descriptor.traitCount(ISmolJoeArt.TraitType.Original, ISmolJoeArt.Brotherhood.None),
            100,
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
