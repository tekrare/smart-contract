// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC1155Supply.sol";
import "./AccessControl.sol";
import "./Payable.sol";

contract TekRare is ERC1155Supply, AccessControl, Payable {
  constructor (string memory uri) ERC1155(uri) {}
}
