// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface ITekRare {
  function tokenAmount() external view returns (uint);
  function setUri(string memory uri) external;
  function mint(address to, uint tokenId, uint amount) external;
  function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) external;
}
