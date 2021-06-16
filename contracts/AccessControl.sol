// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

abstract contract AccessControl {
  address private owner;
  mapping (address => bool) private admins;

  constructor () {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyAdmin() {
    require(msg.sender == owner || admins[msg.sender]);
    _;
  }

  function giveAdminRole(address admin) public onlyOwner {
    admins[admin] = true;
  }
}
