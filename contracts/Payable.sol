// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./AccessControl.sol";

contract Payable is AccessControl {
  fallback () external payable {}

  receive () external payable {}

  function getBalance() public view onlyAdmin returns (uint) {
    return address(this).balance;
  }

  function withdrawBalance() public onlyOwner {
    payable(msg.sender).transfer(getBalance());
  }
}
