// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./AccessControl.sol";

abstract contract Payable is AccessControl {
  fallback () external payable {}

  receive () external payable {}

  function getBalance() public view onlyAdmin returns (uint) {
    return address(this).balance;
  }

  function withdrawBalance() public onlyOwner {
    payable(msg.sender).transfer(getBalance());
  }
}
