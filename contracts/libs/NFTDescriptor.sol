// SPDX-License-Identifier: GPL-3.0

/// @author NounsDAO: https://github.com/nounsDAO/nouns-monorepo
/// @title A library used to construct ERC721 token URIs and SVG images

/**
 *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *
 */

pragma solidity ^0.8.6;

import {Base64} from "base64-sol/base64.sol";
import {ISVGRenderer} from "../interfaces/ISVGRenderer.sol";

library NFTDescriptor {
    struct TokenURIParams {
        string name;
        string description;
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
                            _generateTraitData(params.parts),
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
    function _generateTraitData(ISVGRenderer.Part[] memory parts) internal pure returns (string memory traitData) {
        string[9] memory traitNames =
            ["Background", "Body", "Pants", "Shoes", "Shirt", "Beard", "Head", "Eye", "Accesory"];

        traitData = string(abi.encodePacked("["));
        for (uint256 i = 0; i < parts.length; i++) {
            traitData = string(
                abi.encodePacked(traitData, '{"trait_type":"', traitNames[i], '","value":"', parts[i].name, '"}')
            );

            if (i < parts.length - 1) {
                traitData = string(abi.encodePacked(traitData, ","));
            }
        }

        traitData = string(abi.encodePacked(traitData, "]"));

        return traitData;
    }
}
