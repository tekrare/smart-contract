// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./IAuctionManager.sol";

interface ITekRare is IERC1155, IAuctionManager {
  function tokenAmount() external view returns (uint);
  function setUri(string memory uri) external;
  function mint(address to, uint tokenId, uint amount) external;
  function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) external;
  function mintAndAuction(uint tokenId, uint amount, uint startingBid, uint biddingTime) external;
  function mintBatchAndAuction(
    uint[] memory tokenIds,
    uint[] memory amounts,
    uint[] memory startingBids,
    uint[] memory biddingTimes
  ) external;
  function collectEndedAuctions() external returns (uint);
}
