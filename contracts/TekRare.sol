// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC1155Supply.sol";
import "./AccessControl.sol";
import "./Payable.sol";
import "./ITekRare.sol";
import "./AuctionManager.sol";

contract TekRare is ITekRare, ERC1155Supply, AccessControl, Payable, AuctionManager {
  uint public override tokenAmount;

  constructor (string memory uri) ERC1155(uri) AuctionManager(payable(this)) {}

  function setUri(string memory uri) public override onlyAdmin {
    _setURI(uri);
  }

  function mint(address to, uint tokenId, uint amount) public override onlyAdmin {
    _mint(to, tokenId, amount, "");
    tokenAmount++;
  }

  function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) public override onlyAdmin {
    _mintBatch(to, tokenIds, amounts, "");
    tokenAmount += tokenIds.length;
  }

  function mintAndAuction(
    uint tokenId,
    uint amount,
    uint startingBid,
    uint biddingTime
  ) public override onlyAdmin {
    _mint(address(this), tokenId, amount, "");
    tokenAmount++;
    _createGenesisAuction(startingBid, biddingTime, tokenId);
  }

  function mintBatchAndAuction(
    uint[] memory tokenIds,
    uint[] memory amounts,
    uint[] memory startingBids,
    uint[] memory biddingTimes
  ) public override onlyAdmin {
    _mintBatch(address(this), tokenIds, amounts, "");
    tokenAmount += tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++)
      _createGenesisAuction(startingBids[i], biddingTimes[i], tokenIds[i]);
  }
}
