
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AuctionManager.sol";

abstract contract Auctionable is AuctionManager {
  function mintAndAuction(
    uint tokenId,
    uint amount,
    uint startingBid,
    uint biddingTime
  ) public onlyAdmin {
    _mint(address(this), tokenId, amount, "");
    tokenAmount++;
    _createGenesisAuction(startingBid, biddingTime, tokenId);
  }
}
