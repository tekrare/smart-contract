// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Payable.sol";
import "./ERC1155Supply.sol";

abstract contract Mintable is Payable, ERC1155Supply {
  uint public tokenAmount;

  function mint(address to, uint tokenId, uint amount) public onlyAdmin {
    _mint(to, tokenId, amount, "");
    tokenAmount++;
  }
}
