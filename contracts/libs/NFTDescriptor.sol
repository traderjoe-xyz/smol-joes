// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {Base64} from "base64-sol/base64.sol";
import {ISVGRenderer} from "../interfaces/ISVGRenderer.sol";
import {ISmolJoeArt} from "../interfaces/ISmolJoeArt.sol";

/// @title A library used to construct ERC721 token URIs and SVG images
library NFTDescriptor {
    struct TokenURIParams {
        string name;
        string description;
        ISmolJoeArt.Brotherhood brotherhood;
        ISVGRenderer.Part[] parts;
    }

    /**
     * @notice Construct an ERC721 token URI.
     */
    function constructTokenURI(ISVGRenderer renderer, TokenURIParams memory params)
        internal
        view
        returns (string memory)
    {
        string memory image = generateSVGImage(renderer, ISVGRenderer.SVGParams({parts: params.parts}));

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
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
            )
        );
    }

    /**
     * @notice Generate an SVG image for use in the ERC721 token URI.
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
     */
    function _generateTraitData(ISVGRenderer.Part[] memory parts, ISmolJoeArt.Brotherhood brotherhood)
        internal
        pure
        returns (string memory traitData)
    {
        string[9] memory traitNames =
            ["Background", "Body", "Pants", "Shoes", "Shirt", "Beard", "Head", "Eye", "Accesory"];

        // forgefmt: disable-next-item
        string[11] memory brotherhoodNames = [
            "None", "Academics", "Athletes", "Creatives", "Gentlemans", "MagicalBeings",
            "Military",  "Musicians",  "Outlaws", "Religious", "Superheros"
        ];

        traitData = string(abi.encodePacked("["));

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

    function _appendTrait(string memory traitData, string memory traitName, string memory traitValue)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(traitData, '{"trait_type":"', traitName, '","value":"', traitValue, '"}'));
    }
}
