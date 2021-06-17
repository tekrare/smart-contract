// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface ITekRare {
  function setUri(string memory uri) external;
  function mint(address to, uint256 id, uint256 amount, bytes memory data) external;
  function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
}
