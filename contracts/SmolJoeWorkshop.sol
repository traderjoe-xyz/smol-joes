// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {ISmolJoes} from "./interfaces/ISmolJoes.sol";
import {ISmolJoeSeeder} from "./interfaces/ISmolJoeSeeder.sol";
import {ISmolJoeWorkshop} from "./interfaces/ISmolJoeWorkshop.sol";

/**
 * @title The Smol Joe workshop contract, to buy and upgrade Smol Joes
 */
contract SmolJoeWorkshop is ISmolJoeWorkshop, Ownable2Step, Pausable {
    struct MintPhase {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        uint256 mintStartId;
        uint256 mintEndId;
    }

    address private constant BURN_ADDRESS = address(0xdead);

    uint256 public originalsUpgradePrice;
    uint256 public luminaryUpgradePrice;
    uint256 public commonUpgradePrice;

    uint256 public mintPrice;

    IERC721 public immutable smolJoes;
    IERC721 public immutable smolCreeps;
    IERC721 public immutable beegPumpkins;
    IERC721 public immutable smolPumpkins;

    ISmolJoes public immutable newSmolJoes;

    constructor(
        ISmolJoes _newSmolJoes,
        IERC721 _smolJoes,
        IERC721 _smolCreeps,
        IERC721 _beegPumpkins,
        IERC721 _smolPumpkins
    ) {
        newSmolJoes = _newSmolJoes;
        smolJoes = _smolJoes;
        smolCreeps = _smolCreeps;
        beegPumpkins = _beegPumpkins;
        smolPumpkins = _smolPumpkins;
    }

    function mint(uint256 amount) external payable whenNotPaused {
        newSmolJoes.mint(msg.sender, amount);
        _refundIfOver(mintPrice * amount);
    }

    function upgradeSmolJoe(uint256 tokenId) external whenNotPaused {
        smolJoes.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mint(msg.sender, tokenId);
        _refundIfOver(originalsUpgradePrice);
    }

    function upgradeUniqueSmolCreepWithPumpkin(uint256 tokenId, uint256 pumpkinTokenId) external whenNotPaused {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        beegPumpkins.transferFrom(msg.sender, BURN_ADDRESS, pumpkinTokenId);
        newSmolJoes.mint(msg.sender, tokenId);
        _refundIfOver(originalsUpgradePrice);
    }

    function upgradeUniqueSmolCreep(uint256 tokenId) external whenNotPaused {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mint(msg.sender, tokenId);
        _refundIfOver(originalsUpgradePrice);
    }

    function upgradeSmolCreepWithPumpkin(uint256 tokenId, uint256 pumpkinTokenId) external whenNotPaused {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        smolPumpkins.transferFrom(msg.sender, BURN_ADDRESS, pumpkinTokenId);
        newSmolJoes.mint(msg.sender, tokenId);
        _refundIfOver(luminaryUpgradePrice);
    }

    function upgradeSmolCreep(uint256 tokenId) external whenNotPaused {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mint(msg.sender, tokenId);
        _refundIfOver(luminaryUpgradePrice);
    }

    function setPrices(uint256 newSpecialUpgradePrice, uint256 newUniqueUpgradePrice, uint256 newCommonUpgradePrice)
        external
        onlyOwner
    {
        originalsUpgradePrice = newSpecialUpgradePrice;
        luminaryUpgradePrice = newUniqueUpgradePrice;
        commonUpgradePrice = newCommonUpgradePrice;
    }

    function withdrawAVAX(address to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success,) = to.call{value: amount}("");

        if (!success) {
            revert SmolJoeWorkshop__TransferFailed();
        }
    }

    function _refundIfOver(uint256 _price) internal {
        if (msg.value < _price) {
            revert SmolJoeWorkshop__NotEnoughAVAX();
        }
        if (msg.value > _price) {
            (bool success,) = msg.sender.call{value: msg.value - _price}("");
            if (!success) {
                revert SmolJoeWorkshop__TransferFailed();
            }
        }
    }
}
