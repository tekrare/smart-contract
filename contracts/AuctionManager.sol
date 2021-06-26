// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Auction.sol";
import "./Mintable.sol";

abstract contract AuctionManager is Mintable {
  mapping (uint => Auction[]) auctions;
  uint8 contractPercentage = 15;

  // Event that will be emitted on changes.
  event HighestBidIncreased(address seller, uint tokenId, address bidder, uint amount);

  function _getAuction(uint tokenId, address seller) internal view returns (Auction storage) {
    Auction storage auction;

    for (uint i = 0; i < auctions[tokenId].length; i++) {
      auction = auctions[tokenId][i];
      if (auction.seller == seller) {
        return auction;
      }
    }
    revert("Auction not found");
  }

  function _hasAlreadyAnAuction(uint tokenId, address seller) internal view returns (bool) {
    Auction storage auction;

    for (uint i = 0; i < auctions[tokenId].length; i++) {
      auction = auctions[tokenId][i];
      if (auction.seller == seller) {
        return true;
      }
    }
    return false;
  }

  function _createAuction(uint tokenId, uint startingBid, uint biddingTime, address payable seller) internal {
    uint arrayLength = auctions[tokenId].length;
    auctions[tokenId].push();
    Auction storage auction = auctions[tokenId][arrayLength];

    auction.seller = seller;
    auction.endTime = block.timestamp + biddingTime;
    auction.startTime = block.timestamp;
    auction.startingBid = startingBid;
  }

  function _createGenesisAuction(uint startingBid, uint biddingTime, uint tokenId) internal {
    _createAuction(tokenId, startingBid, biddingTime, payable(address(this)));
  }

  function _hasBid(Auction storage auction) internal view returns (bool) {
    for (uint i = 0; i < auction.bids.length; i++) {
      if (auction.bids[i].bidder == msg.sender)
        return true;
    }
    return false;
  }

  function _hasPendingReturn(Auction storage auction) internal view returns (bool) {
    return auction.pendingReturns[msg.sender] > 0;
  }

  function _highestBidder(Auction storage auction) internal view returns (address) {
    if (auction.bids.length == 0)
      return address(0);
    return auction.bids[auction.bids.length - 1].bidder;
  }

  function _highestBid(Auction storage auction) internal view returns (uint) {
    if (auction.bids.length == 0)
      return auction.startingBid;
    return auction.bids[auction.bids.length - 1].price;
  }

  function _bidAuction(Auction storage auction) internal {
    require(block.timestamp < auction.endTime, "Auction already ended");
    require(msg.value > ((_highestBid(auction) * 110) / 100), "Value needs to be higher");
    require(_highestBidder(auction) != msg.sender, "Account is the highest bidder");

    if (auction.bids.length != 0) {
      auction.pendingReturns[_highestBidder(auction)] += _highestBid(auction);
    }
    auction.bids.push(Bid(msg.sender, msg.value));
  }

  function _withdrawForSeller(Auction storage auction) internal returns (uint) {
    require(block.timestamp >= auction.endTime, "Auction not yet ended");
    require(!auction.sellerPayed, "Seller already payed");

    uint sellerRevenue = (_highestBid(auction) * (100 - contractPercentage)) / 100;

    auction.sellerPayed = true;
    // Send (100 - contractPercentage)% of the auction to the seller and keep contractPercentage% for the AuctionManager
    auction.seller.transfer(sellerRevenue);
    return sellerRevenue;
  }

  function _withdrawOverbid(Auction storage auction) internal returns (bool, uint) {
    require(_hasBid(auction), "Account did not bid");

    uint amount = auction.pendingReturns[msg.sender];

    if (amount > 0) {
      auction.pendingReturns[msg.sender] = 0;

      if (!payable(msg.sender).send(amount)) {
        auction.pendingReturns[msg.sender] = amount;
        return (false, 0);
      }
    }
    return (true, amount);
  }

  // function collectEndedAuctions() public onlyAdmin returns (uint) {
  //   Auction auction;
  //   uint totalRevenue = 0;
  
  //   for (uint i = 0; i < tokenAmount; i++) {
  //     for (uint j = 0; j < auctions[i].length; j++) {
  //       auction = auctions[i][j];
  //       if (block.timestamp >= auction.endTime() && !auction.auctionManagerPayed()) {
  //         totalRevenue += auction.withdrawForAuctionManager();
  //       }
  //     }
  //   }
  //   return totalRevenue;
  // }

  function createAuction(uint startingBid, uint biddingTime, uint tokenId) public {
    require(biddingTime <= 60 * 60 * 24 * 10, "Bidding time is too high");
    require(!_hasAlreadyAnAuction(tokenId, msg.sender), "Auction already exists");
    require(balanceOf(msg.sender, tokenId) > 0, "Unauthorized account");

    safeTransferFrom(msg.sender, address(this), tokenId, 1, "");
    _createAuction(tokenId, startingBid, biddingTime, payable(msg.sender));
  }

  function bidAuction(uint tokenId, address seller) public payable {
    Auction storage auction = _getAuction(tokenId, seller);
    
    _bidAuction(auction);
    emit HighestBidIncreased(seller, tokenId, msg.sender, msg.value);
  }

  function withdrawAuction(uint tokenId, address seller) public returns (bool, uint) {
    Auction storage auction = _getAuction(tokenId, seller);
    bool transferSuccess = true;
    uint withdrawnAmount = 0;

    if (seller == msg.sender)
      withdrawnAmount = _withdrawForSeller(auction);
    else
      (transferSuccess, withdrawnAmount) = _withdrawOverbid(auction);
    return (transferSuccess, withdrawnAmount);
  }

  function collectAuctionReward(uint tokenId, address seller) public {
    Auction storage auction = _getAuction(tokenId, seller);
    require(block.timestamp >= auction.endTime, "Auction not yet ended");
    require(msg.sender == _highestBidder(auction), "Account did not win the auction");
    safeTransferFrom(address(this), msg.sender, tokenId, 1, "");
  }

  function getPendingReturnAuctions() public view returns (AuctionData[] memory) {
    AuctionData[] memory auctionsData;
    Auction storage auction;
    uint32 index = 0;

    for (uint i = 0; i < tokenAmount; i++) {
      for (uint j = 0; j < auctions[i].length; j++) {
        auction = auctions[i][j];
        if (_hasPendingReturn(auction)) {
          auctionsData[index] = AuctionData(
            auction.bids,
            Bid(_highestBidder(auction), _highestBid(auction)),
            auction.seller,
            auction.startTime,
            auction.endTime,
            auction.seller == address(this)
          );
          index++;
        }
      } 
    }
    return auctionsData;
  }

  function getAuctions() public view returns (AuctionData[] memory) {
    AuctionData[] memory auctionsData;
    Auction storage auction;
    uint32 index = 0;

    for (uint i = 0; i < tokenAmount; i++) {
      for (uint j = 0; j < auctions[i].length; j++) {
        auction = auctions[i][j];
        auctionsData[index] = AuctionData(
          auction.bids,
          Bid(_highestBidder(auction), _highestBid(auction)),
          auction.seller,
          auction.startTime,
          auction.endTime,
          auction.seller == address(this)
        );
        index++;
      } 
    }
    return auctionsData;
  }

  function getAuction(uint tokenId, address seller) public view returns (AuctionData memory) {
    Auction storage auction = _getAuction(tokenId, seller);

    return AuctionData(
      auction.bids,
      Bid(_highestBidder(auction), _highestBid(auction)),
      auction.seller,
      auction.startTime,
      auction.endTime,
      auction.seller == address(this)
    );
  }

  function setContractPercentage(uint8 _contractPercentage) public onlyAdmin {
    contractPercentage = _contractPercentage;
  }
}
