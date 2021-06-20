// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./AuctionData.sol";
import "./Payable.sol";

contract Auction is Payable {
  // Parameters of the auction. Times are either
  // absolute unix timestamps (seconds since 1970-01-01)
  // or time periods in seconds.
  address payable auctionManager; 
  address payable public seller;
  uint public endTime;
  uint public startTime;

  // Minimal bid to start the auction
  uint startingBid;

  // Allowed withdrawals of previous bids
  mapping(address => uint) pendingReturns;

  // Set to true at the end, disallows any change.
  // By default initialized to `false`.
  bool sellerPayed;
  bool public auctionManagerPayed;

  // Bid history
  // Current State of the auction is the last value of the array
  Bid[] bids;

  // Create a simple auction with `_biddingTime`
  // seconds bidding time on behalf of the
  // seller address `_seller`.
  constructor(uint _startingBid, uint _biddingTime, address payable _seller, address payable _auctionManager) {
    seller = _seller;
    endTime = block.timestamp + _biddingTime;
    startTime = block.timestamp;
    startingBid = _startingBid;
    auctionManager = _auctionManager;
  }

  function _hasBid(address potentialBidder) private view returns (bool) {
    for (uint i = 0; i < bids.length; i++) {
      if (bids[i].bidder == potentialBidder)
        return true;
    }
    return false;
  }

  function hasPendingReturn(address sender) public view returns (bool) {
    return pendingReturns[sender] > 0;
  }

  function highestBidder() public view returns (address) {
    if (bids.length == 0)
      return address(0);
    return bids[bids.length - 1].bidder;
  }

  function highestBid() public view returns (uint) {
    if (bids.length == 0)
      return startingBid;
    return bids[bids.length - 1].price;
  }

  // Bid on the auction with the value sent
  // together with this transaction.
  // The value will only be refunded if the
  // auction is not won.
  function bid(address sender, uint value) public {
    require(block.timestamp < endTime, "Auction already ended.");
    require(value > ((highestBid() * 110) / 100), "Value needs to be higher.");
    require(highestBidder() != sender, "Sender already has the highest bid.");

    if (bids.length != 0) {
      pendingReturns[highestBidder()] += highestBid();
    }
    bids.push(Bid(sender, value));
  }

  // Withdraw a bid that was overbid.
  function withdraw(address sender) public returns (bool, uint) {
    require(_hasBid(sender), "Sender did not bid on this auction.");

    uint amount = pendingReturns[sender];

    if (amount > 0) {
      pendingReturns[sender] = 0;

      if (!payable(sender).send(amount)) {
        pendingReturns[sender] = amount;
        return (false, 0);
      }
    }
    return (true, amount);
  }

  // End the auction and send the highest bid
  // to the seller.
  function withdrawForSeller() public returns (uint) {
    require(block.timestamp >= endTime, "Auction not yet ended.");
    require(!sellerPayed, "Seller has already been payed.");

    uint sellerRevenue = (highestBid() * 85) / 100;

    sellerPayed = true;
    seller.transfer(sellerRevenue); // Send 85% of the auction to the seller and keep 15% for the AuctionManager
    return sellerRevenue;
  }

  function withdrawForAuctionManager() public returns (uint) {
    if (block.timestamp < endTime || auctionManagerPayed)
      return 0;

    uint auctionManagerRevenue = (highestBid() * 15) / 100;

    auctionManagerPayed = true;
    auctionManager.transfer(auctionManagerRevenue); // Send 15% of the auction to the AuctionManager
    return auctionManagerRevenue;
  }

  function getBids() public view returns (Bid[] memory) {
    return bids;
  }
}
