// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Auctionable.sol";

contract TekRare is Auctionable {
  constructor () ERC1155("https://tekrare.fr/{id}") {}

  function setUri(string memory uri) public onlyAdmin {
    _setURI(uri);
  }
}
