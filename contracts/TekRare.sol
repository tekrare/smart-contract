// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC1155Supply.sol";
import "./AccessControl.sol";
import "./Payable.sol";

contract TekRare is ERC1155Supply, AccessControl, Payable {
  constructor (string memory uri) ERC1155(uri) {}

  function setUri(string memory uri) public onlyAdmin {
    _setURI(uri);
  }

  function mint(address to, uint256 id, uint256 amount, bytes memory data) public onlyAdmin {
    _mint(to, id, amount, data);
  }

  function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyAdmin {
    _mintBatch(to, ids, amounts, data);
  }
}
