// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

struct Bid {
  address bidder;
  uint price;
}

struct AuctionData {
  Bid[] bids;
  Bid highestBid;
  address seller;
  uint startTime;
  uint endTime;
  bool genesis; // Is an auction created by TekRare
}
