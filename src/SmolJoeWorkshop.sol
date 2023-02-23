// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

import {Ownable2Step} from "openzeppelin/access/Ownable2Step.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {IERC721} from "openzeppelin/token/ERC721/IERC721.sol";

import {ISmolJoes} from "./interfaces/ISmolJoes.sol";
import {ISmolJoeWorkshop} from "./interfaces/ISmolJoeWorkshop.sol";

/// @title The Smol Joe workshop contract, to buy and upgrade Smol Joes
contract SmolJoeWorkshop is ISmolJoeWorkshop, Ownable2Step, Pausable {
    enum UpgradeType {
        SmolJoe,
        UniqueSmolCreepWithPumpkin,
        UniqueSmolCreep,
        SmolCreepWithPumpkin,
        SmolCreep
    }

    struct MintPhase {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint256 price;
        uint256 mintStartId;
        uint256 mintEndId;
    }

    address private constant BURN_ADDRESS = address(0xdead);

    uint256 public specialUpgradePrice;
    uint256 public uniqueUpgradePrice;
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

    function upgradeNFT(uint256 tokenId, UpgradeType upgradeType) external payable whenNotPaused {
        if (upgradeType == UpgradeType.SmolJoe) {
            _upgradeSmolJoe(tokenId);
        } else if (upgradeType == UpgradeType.UniqueSmolCreepWithPumpkin) {
            _upgradeUniqueSmolCreepWithPumpkin(tokenId);
        } else if (upgradeType == UpgradeType.UniqueSmolCreep) {
            _upgradeUniqueSmolCreep(tokenId);
        } else if (upgradeType == UpgradeType.SmolCreepWithPumpkin) {
            _upgradeSmolCreepWithPumpkin(tokenId);
        } else if (upgradeType == UpgradeType.SmolCreep) {
            _upgradeSmolCreep(tokenId);
        } else {
            revert SmolJoeWorkshop__InvalidUpgradeType();
        }
    }

    function _upgradeSmolJoe(uint256 tokenId) internal {
        smolJoes.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mintSpecial(msg.sender, tokenId);
        _refundIfOver(specialUpgradePrice);
    }

    function _upgradeUniqueSmolCreepWithPumpkin(uint256 tokenId) internal {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        beegPumpkins.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mintSpecial(msg.sender, tokenId);
        _refundIfOver(specialUpgradePrice);
    }

    function _upgradeUniqueSmolCreep(uint256 tokenId) internal {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mintSpecial(msg.sender, tokenId);
        _refundIfOver(specialUpgradePrice);
    }

    function _upgradeSmolCreepWithPumpkin(uint256 tokenId) internal {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        smolPumpkins.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mintSpecial(msg.sender, tokenId);
        _refundIfOver(uniqueUpgradePrice);
    }

    function _upgradeSmolCreep(uint256 tokenId) internal {
        smolCreeps.transferFrom(msg.sender, BURN_ADDRESS, tokenId);
        newSmolJoes.mintSpecial(msg.sender, tokenId);
        _refundIfOver(uniqueUpgradePrice);
    }

    function setPrices(uint256 newSpecialUpgradePrice, uint256 newUniqueUpgradePrice, uint256 newCommonUpgradePrice)
        external
        onlyOwner
    {
        specialUpgradePrice = newSpecialUpgradePrice;
        uniqueUpgradePrice = newUniqueUpgradePrice;
        commonUpgradePrice = newCommonUpgradePrice;
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
