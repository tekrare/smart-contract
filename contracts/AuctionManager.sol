// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Auction.sol";
import "./ITekRare.sol";
import "./AuctionData.sol";

abstract contract AuctionManager is IAuctionManager {
  mapping (uint => Auction[]) auctions;
  ITekRare owner;
  uint8 contractPercentage = 15;

  constructor (address payable _owner) {
    owner = ITekRare(_owner);
  }

  // Event that will be emitted on changes.
  event HighestBidIncreased(address seller, uint tokenId, address bidder, uint amount);

  function _getAuction(uint tokenId, address seller) private view returns (Auction) {
    Auction auction;

    for (uint i = 0; i < auctions[tokenId].length; i++) {
      auction = auctions[tokenId][i];
      if (auction.seller() == seller) {
        return auction;
      }
    }
    revert("No auction found with this token and this seller.");
  }

  function _hasAlreadyAnAuction(uint tokenId, address seller) private view returns (bool) {
    Auction auction;

    for (uint i = 0; i < auctions[tokenId].length; i++) {
      auction = auctions[tokenId][i];
      if (auction.seller() == seller) {
        return true;
      }
    }
    return false;
  }

  function _createGenesisAuction(uint startingBid, uint biddingTime, uint tokenId) internal {
    address payable thisPayable = payable(address(this));

    auctions[tokenId].push(new Auction(startingBid, biddingTime, thisPayable, thisPayable, contractPercentage));
  }

  function _collectEndedAuctions() internal returns (uint) {
    Auction auction;
    uint tokenAmount = owner.tokenAmount();
    uint totalRevenue = 0;
  
    for (uint i = 0; i < tokenAmount; i++) {
      for (uint j = 0; j < auctions[i].length; j++) {
        auction = auctions[i][j];
        if (block.timestamp >= auction.endTime() && !auction.auctionManagerPayed()) {
          totalRevenue += auction.withdrawForAuctionManager();
        }
      }
    }
    return totalRevenue;
  }

  function createAuction(uint startingBid, uint biddingTime, uint tokenId) public override {
    require(biddingTime <= 60 * 60 * 24 * 10, "Bidding time cannot be higher than 10 days.");
    require(!_hasAlreadyAnAuction(tokenId, msg.sender), "Auction already exists for this token and this seller.");
    require(owner.balanceOf(msg.sender, tokenId) > 0, "Token is not owned by this account.");

    owner.safeTransferFrom(msg.sender, address(this), tokenId, 1, "");
    auctions[tokenId].push(new Auction(startingBid, biddingTime, payable(msg.sender), payable(address(this)), contractPercentage));
  }

  function bidAuction(uint tokenId, address seller) public override payable {
    Auction auction = _getAuction(tokenId, seller);
    
    auction.bid(msg.sender, msg.value);
    // Transfer the msg value to the Auction contract in order to refund and pay the seller inside Auction contract
    payable(address(auction)).transfer(msg.value);
    emit HighestBidIncreased(seller, tokenId, msg.sender, msg.value);
  }

  function withdrawAuction(uint tokenId, address seller) public override returns (bool, uint) {
    Auction auction = _getAuction(tokenId, seller);
    bool transferSuccess = true;
    uint withdrawnAmount = 0;

    if (seller == msg.sender)
      withdrawnAmount = auction.withdrawForSeller();
    else
      (transferSuccess, withdrawnAmount) = auction.withdraw(msg.sender);
    return (transferSuccess, withdrawnAmount);
  }

  function collectAuctionReward(uint tokenId, address seller) public override {
    Auction auction = _getAuction(tokenId, seller);
    require(block.timestamp >= auction.endTime(), "Auction not yet ended.");
    require(msg.sender == auction.highestBidder(), "Sender is not the highest bidder of the auction.");
    owner.safeTransferFrom(address(this), msg.sender, tokenId, 1, "");
  }

  function getPendingReturnAuctions() public view returns (AuctionData[] memory) {
    AuctionData[] memory auctionsData;
    Auction auction;
    uint tokenAmount = owner.tokenAmount();
    uint32 index = 0;

    for (uint i = 0; i < tokenAmount; i++) {
      for (uint j = 0; j < auctions[i].length; j++) {
        auction = auctions[i][j];
        if (auction.hasPendingReturn(msg.sender)) {
          auctionsData[index] = AuctionData(
            auction.getBids(),
            Bid(auction.highestBidder(), auction.highestBid()),
            auction.seller(),
            auction.startTime(),
            auction.endTime(),
            auction.seller() == address(this)
          );
          index++;
        }
      } 
    }
    return auctionsData;
  }

  function getAuctions() public override view returns (AuctionData[] memory) {
    AuctionData[] memory auctionsData;
    Auction auction;
    uint tokenAmount = owner.tokenAmount();
    uint32 index = 0;

    for (uint i = 0; i < tokenAmount; i++) {
      for (uint j = 0; j < auctions[i].length; j++) {
        auction = auctions[i][j];
        auctionsData[index] = AuctionData(
          auction.getBids(),
          Bid(auction.highestBidder(), auction.highestBid()),
          auction.seller(),
          auction.startTime(),
          auction.endTime(),
          auction.seller() == address(this)
        );
        index++;
      } 
    }
    return auctionsData;
  }

  function getAuction(uint tokenId, address seller) public override view returns (AuctionData memory) {
    Auction auction = _getAuction(tokenId, seller);

    return AuctionData(
      auction.getBids(),
      Bid(auction.highestBidder(), auction.highestBid()),
      auction.seller(),
      auction.startTime(),
      auction.endTime(),
      auction.seller() == address(this)
    );
}
