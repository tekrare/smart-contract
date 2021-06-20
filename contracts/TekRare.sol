// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC1155Supply.sol";
import "./AccessControl.sol";
import "./Payable.sol";
import "./ITekRare.sol";

contract TekRare is ITekRare, ERC1155Supply, AccessControl, Payable {
  uint public override tokenAmount;

  constructor (string memory uri) ERC1155(uri) {}

  function setUri(string memory uri) public override onlyAdmin {
    _setURI(uri);
  }

  function mint(address to, uint tokenId, uint amount) public override onlyAdmin {
    _mint(to, tokenId, amount, "");
    tokenAmount++;
  }

  function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) public override onlyAdmin {
    _mintBatch(to, tokenIds, amounts, "");
    tokenAmount += tokenIds.length;
  }
}
