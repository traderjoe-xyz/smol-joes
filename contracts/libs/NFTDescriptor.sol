// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {Base64} from "base64-sol/base64.sol";
import {ISVGRenderer} from "../interfaces/ISVGRenderer.sol";
import {ISmolJoeArt} from "../interfaces/ISmolJoeArt.sol";

/**
 * @title A library used to construct ERC721 token URIs and SVG images
 * @notice Based on NounsDAO: https://github.com/nounsDAO/nouns-monorepo
 */
library NFTDescriptor {
    struct TokenURIParams {
        string name;
        string description;
        ISmolJoeArt.Brotherhood brotherhood;
        string emblem;
        ISVGRenderer.Part[] parts;
    }

    /**
     * @notice Construct an ERC721 token URI.
     * @param renderer The SVG renderer contract.
     * @param params The parameters used to construct the token URI.
     * @return The constructed token URI.
     */
    function constructTokenURI(ISVGRenderer renderer, TokenURIParams memory params)
        internal
        view
        returns (string memory)
    {
        string memory image =
            generateSVGImage(renderer, ISVGRenderer.SVGParams({parts: params.parts, emblem: params.emblem}));

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        '{"name":"',
                        params.name,
                        '", "description":"',
                        params.description,
                        '", "attributes":',
                        _generateTraitData(params.parts, params.brotherhood),
                        ', "image": "',
                        "data:image/svg+xml;base64,",
                        image,
                        '"}'
                    )
                )
            )
        );
    }

    /**
     * @notice Generate an SVG image for use in the ERC721 token URI.
     * @param renderer The SVG renderer contract.
     * @param params The parameters used to construct the SVG image.
     * @return svg The constructed SVG image.
     */
    function generateSVGImage(ISVGRenderer renderer, ISVGRenderer.SVGParams memory params)
        internal
        view
        returns (string memory svg)
    {
        return Base64.encode(bytes(renderer.generateSVG(params)));
    }

    /**
     * @notice Generate the trait data for an ERC721 token.
     * @param parts The parts used to construct the token.
     * @param brotherhood The brotherhood of the token.
     * @return traitData The constructed trait data.
     */
    function _generateTraitData(ISVGRenderer.Part[] memory parts, ISmolJoeArt.Brotherhood brotherhood)
        internal
        pure
        returns (string memory traitData)
    {
        string[9] memory traitNames =
            ["Background", "Body", "Shoes", "Pants", "Shirt", "Beard", "HairCapHead", "EyeAccessory", "Accesory"];

        // forgefmt: disable-next-item
        string[11] memory brotherhoodNames = [
            "None", "Academics", "Athletes", "Creatives", "Gentlemans", "MagicalBeings",
            "Military",  "Musicians",  "Outlaws", "Religious", "Superheros"
        ];

        traitData = "[";

        traitData = _appendTrait(traitData, "Brotherhood", brotherhoodNames[uint8(brotherhood)]);
        traitData = string(abi.encodePacked(traitData, ","));

        // Originals and Luminarys have a single part
        if (parts.length == 1) {
            traitData =
                _appendTrait(traitData, "Rarity", brotherhood == ISmolJoeArt.Brotherhood.None ? "Original" : "Luminary");
            traitData = string(abi.encodePacked(traitData, ","));

            for (uint256 i = 0; i < traitNames.length; i++) {
                traitData = _appendTrait(traitData, traitNames[i], parts[0].name);

                if (i < traitNames.length - 1) {
                    traitData = string(abi.encodePacked(traitData, ","));
                }
            }
        } else {
            traitData = _appendTrait(traitData, "Rarity", "Generative");
            traitData = string(abi.encodePacked(traitData, ","));

            for (uint256 i = 0; i < parts.length; i++) {
                traitData = _appendTrait(traitData, traitNames[i], parts[i].name);

                if (i < parts.length - 1) {
                    traitData = string(abi.encodePacked(traitData, ","));
                }
            }
        }

        traitData = string(abi.encodePacked(traitData, "]"));

        return traitData;
    }

    /**
     * @dev Append a trait to the trait data.
     * @param traitData The trait data to append to.
     * @param traitName The name of the trait.
     * @param traitValue The value of the trait.
     * @return traitData The appended trait data.
     */
    function _appendTrait(string memory traitData, string memory traitName, string memory traitValue)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(traitData, '{"trait_type":"', traitName, '","value":"', traitValue, '"}'));
    }
}
