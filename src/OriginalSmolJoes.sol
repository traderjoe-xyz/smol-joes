// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {OZNFTBaseUpgradeable, IOZNFTBaseUpgradeable} from "nft-base-contracts/OZNFTBaseUpgradeable.sol";
import {
    ONFT721CoreUpgradeable, IONFT721CoreUpgradeable
} from "nft-base-contracts/layerZero/ONFT721CoreUpgradeable.sol";

import {ISmolJoeDescriptorMinimal} from "./interfaces/ISmolJoeDescriptorMinimal.sol";
import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoes} from "./interfaces/ISmolJoes.sol";

/**
 * @title The Smol Joe ERC-721 token
 */
contract OriginalSmolJoes is OZNFTBaseUpgradeable, ISmolJoes {
    /**
     * @notice The Smol Joe token URI descriptor.
     */
    ISmolJoeDescriptorMinimal public override descriptor;

    /**
     * @notice The Smol Joe token seeder.
     * @dev During mint, the seeder will generate a seed for the token.
     * The seed will be used to build the token URI.
     */
    ISmolJoeSeeder public override seeder;

    /**
     * @notice The Smol Joe Workshop, responsible of the token minting.
     * @dev Different sale mechanisms can be implemented in the workshop.
     */
    address public override workshop;

    /**
     * @notice The smol joe seeds
     * @dev Seeds are set by the Smol Joe Seeder during minting.
     * They are used to generate the token URI.
     */
    mapping(uint256 => ISmolJoeSeeder.Seed) private _seeds;

    constructor(
        ISmolJoeDescriptorMinimal _descriptor,
        ISmolJoeSeeder _seeder,
        address _lzEndpoint,
        address _royaltyReceiver
    ) initializer {
        __OZNFTBase_init("OG Smol Joes", "100SJ", _lzEndpoint, 0, _royaltyReceiver, _royaltyReceiver);

        _setDescriptor(_descriptor);
        _setSeeder(_seeder);
    }

    /**
     * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
     * @param tokenId The token ID to get the URI for.
     * @return The URI for the given token ID.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            revert SmolJoes__InexistentToken(tokenId);
        }

        return descriptor.tokenURI(tokenId, _seeds[tokenId]);
    }

    /**
     * @notice Similar to `tokenURI`, but always serves a base64 encoded data URI
     * with the JSON contents directly inlined.
     * @param tokenId The token ID to get the data URI for.
     * @return The data URI for the given token ID.
     */
    function dataURI(uint256 tokenId) public view returns (string memory) {
        if (!_exists(tokenId)) {
            revert SmolJoes__InexistentToken(tokenId);
        }

        return descriptor.dataURI(tokenId, _seeds[tokenId]);
    }

    /**
     * @notice Get the seed for a given token ID.
     * @dev The seed is set by the Smol Joe Seeder during minting.
     * It is used to generate the token URI.
     * @param tokenId The token ID to get the seed for.
     * @return The seed for the given token ID.
     */
    function getTokenSeed(uint256 tokenId) external view override returns (ISmolJoeSeeder.Seed memory) {
        if (!_exists(tokenId)) {
            revert SmolJoes__InexistentToken(tokenId);
        }

        return _seeds[tokenId];
    }

    /**
     * @notice Estimate the fee for sending a token to another chain.
     * @dev Overwritten from `ONFT721CoreUpgradeable` to take into account the packed seed added to the payload.
     * @param destinationChainId The chain ID of the destination chain.
     * @param to The address to send the token to.
     * @param tokenId The token ID to send.
     * @param useZro Whether to use ZRO or not to pay for the bridging fees.
     * @param adapterParams The adapter parameters.
     */
    function estimateSendFee(
        uint16 destinationChainId,
        bytes memory to,
        uint256 tokenId,
        bool useZro,
        bytes memory adapterParams
    )
        public
        view
        override(ONFT721CoreUpgradeable, IONFT721CoreUpgradeable)
        returns (uint256 nativeFee, uint256 zroFee)
    {
        bytes memory payload = abi.encode(to, tokenId, _getPackedSeed(tokenId));
        return lzEndpoint.estimateFees(destinationChainId, address(this), payload, useZro, adapterParams);
    }

    /**
     * @notice Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these IDs are created.
     * This function call must use less than 30 000 gas.
     * @param interfaceId InterfaceId to consider. Comes from type(InterfaceContract).interfaceId
     * @return True if the considered interface is supported
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IOZNFTBaseUpgradeable, OZNFTBaseUpgradeable)
        returns (bool)
    {
        return interfaceId == type(ISmolJoes).interfaceId || OZNFTBaseUpgradeable.supportsInterface(interfaceId);
    }

    /**
     * @notice Mint a new token.
     * @dev The mint logic is expected to be handled by the Smol Joe Workshop.
     * The Workshop address can be updated by the owner, allowing the implementation of different sale mechanisms in the future.
     * @param to The address to mint the token to.
     * @param tokenID The token ID to mint.
     */
    function mint(address to, uint256 tokenID) external override {
        if (msg.sender != address(workshop) || tokenID > 99) {
            revert SmolJoes__Unauthorized();
        }

        ISmolJoeSeeder.Seed memory seed;
        seed.originalId = seeder.getOriginalsArtMapping(tokenID) + 1;
        _seeds[tokenID] = seed;

        _mint(to, tokenID);
    }

    /**
     * @notice Set the token URI descriptor.
     * @dev Only callable by the owner when not locked.
     */
    function setDescriptor(ISmolJoeDescriptorMinimal _descriptor) external onlyOwner {
        _setDescriptor(_descriptor);
    }

    /**
     * @notice Set the token seeder.
     * @param _seeder The new seeder address.
     */
    function setSeeder(ISmolJoeSeeder _seeder) external onlyOwner {
        _setSeeder(_seeder);
    }

    /**
     * @notice Set the token workshop.
     * @dev Workshop address can be set to zero to prevent further minting (until upgraded again).
     * @param _workshop The new workshop address.
     */
    function setWorkshop(address _workshop) external onlyOwner {
        _setWorkshop(_workshop);
    }

    /**
     * @dev Gets the seed struct as it is stored in storage.
     * To reduce data sent through the bridge and save gas, we directly use the packed value.
     * This only works is the struct fits in one storage slot.
     * @param tokenId The token ID to get the seed for.
     * @return packedSeed The packed seed.
     */
    function _getPackedSeed(uint256 tokenId) internal view returns (uint256 packedSeed) {
        ISmolJoeSeeder.Seed storage seed = _seeds[tokenId];

        assembly {
            packedSeed := sload(seed.slot)
        }
    }

    /**
     * @dev Stores the packed seed directly in the token seed storage slot.
     * @param tokenId The token ID to store the seed for.
     * @param packedSeed The seed to store. Needs to come from `_getPackedSeed`.
     */
    function _setPackedSeed(uint256 tokenId, uint256 packedSeed) internal {
        ISmolJoeSeeder.Seed storage seed = _seeds[tokenId];

        assembly {
            sstore(seed.slot, packedSeed)
        }
    }

    /**
     * @dev Overwriting the `_send` function of the OZ NFT base contract to add the packed seed to the payload.
     * @param from The address to debit the token from.
     * @param destinationChainId The destination chain ID.
     * @param to The destination address.
     * @param tokenId The token ID to send.
     * @param refundAddress The address to refund the gas fee to.
     * @param zroPaymentAddress The address to pay the Layer Zero fee to.
     * @param adapterParams The adapter parameters.
     */
    function _send(
        address from,
        uint16 destinationChainId,
        bytes memory to,
        uint256 tokenId,
        address payable refundAddress,
        address zroPaymentAddress,
        bytes memory adapterParams
    ) internal override {
        _debitFrom(from, destinationChainId, to, tokenId);

        bytes memory payload = abi.encode(to, tokenId, _getPackedSeed(tokenId));

        if (useCustomAdapterParams) {
            _checkGasLimit(destinationChainId, FUNCTION_TYPE_SEND, adapterParams, NO_EXTRA_GAS);
        } else {
            require(adapterParams.length == 0, "LzApp: adapterParams must be empty.");
        }
        _lzSend(destinationChainId, payload, refundAddress, zroPaymentAddress, adapterParams);

        uint64 nonce = lzEndpoint.getOutboundNonce(destinationChainId, address(this));
        emit SendToChain(from, destinationChainId, to, tokenId, nonce);
    }

    /**
     * @dev Overwriting the `_nonblockingLzReceive` function of the OZ NFT base contract to get the packed seed from the payload.
     * @param sourceChainId The source chain ID.
     * @param sourceAddress The source address.
     * @param nonce The nonce of the transaction.
     * @param payload The payload of the transaction.
     */
    function _nonblockingLzReceive(uint16 sourceChainId, bytes memory sourceAddress, uint64 nonce, bytes memory payload)
        internal
        override
    {
        (bytes memory toAddressBytes, uint256 tokenId, uint256 packedSeed) =
            abi.decode(payload, (bytes, uint256, uint256));

        address toAddress;
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }

        _creditTo(sourceChainId, toAddress, tokenId);
        _setPackedSeed(tokenId, packedSeed);

        emit ReceiveFromChain(sourceChainId, sourceAddress, toAddress, tokenId, nonce);
    }

    /**
     * @notice Set the token URI descriptor.
     * @param _descriptor The new descriptor address.
     */
    function _setDescriptor(ISmolJoeDescriptorMinimal _descriptor) internal {
        if (address(_descriptor) == address(0)) {
            revert SmolJoes__InvalidAddress();
        }

        descriptor = _descriptor;

        emit DescriptorUpdated(address(_descriptor));
    }

    /**
     * @notice Set the token seeder.
     * @dev Only callable by the owner when not locked.
     */
    function _setSeeder(ISmolJoeSeeder _seeder) internal {
        if (address(_seeder) == address(0)) {
            revert SmolJoes__InvalidAddress();
        }

        seeder = _seeder;

        emit SeederUpdated(address(_seeder));
    }

    /**
     * @notice Set the token workshop.
     * @dev Workshop address can be set to zero to prevent further minting (until upgraded again).
     * @param _workshop The new workshop address.
     */
    function _setWorkshop(address _workshop) internal {
        workshop = _workshop;

        emit WorkshopUpdated(_workshop);
    }
}
