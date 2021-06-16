// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./AccessControl.sol";
import "./Payable.sol";

contract TekRare is ERC1155, AccessControl, Payable {
  constructor (string memory uri) ERC1155(uri) {}
}
