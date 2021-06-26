// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

struct Bid {
  address bidder;
  uint price;
}

struct Auction {
  address payable seller;
  uint endTime;
  uint startTime;
  uint startingBid;
  mapping(address => uint) pendingReturns;
  Bid[] bids;
  bool sellerPayed;
}

struct AuctionData {
  Bid[] bids;
  Bid highestBid;
  address seller;
  uint startTime;
  uint endTime;
  bool genesis; // Is an auction created by TekRare
}
