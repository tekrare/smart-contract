// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./AuctionData.sol";

interface IAuctionManager {
  function createAuction(uint startingBid, uint biddingTime, uint tokenId) external;
  function bidAuction(uint tokenId, address seller) external payable;
  function withdrawAuction(uint tokenId, address seller) external returns (bool, uint);
  function collectAuctionReward(uint tokenId, address seller) external;
  function getPendingReturnAuctions() external view returns (AuctionData[] memory);
  function getAuctions() external view returns (AuctionData[] memory);
  function getAuction(uint tokenId, address seller) external view returns (AuctionData memory);
  function setContractPercentage(uint8 contractPercentage) external;
}
