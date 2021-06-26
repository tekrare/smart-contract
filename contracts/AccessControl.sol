// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

abstract contract AccessControl {
  address private owner;
  mapping (address => bool) private admins;

  constructor () {
    owner = msg.sender;
  }

  function _onlyOwner() internal view {
    require(msg.sender == owner);
  }

  function _onlyAdmin() internal view {
    require(msg.sender == owner || admins[msg.sender]);
  }

  modifier onlyOwner() {
    _onlyOwner();
    _;
  }

  modifier onlyAdmin() {
    _onlyAdmin();
    _;
  }

  function giveAdminRole(address admin) public onlyOwner {
    admins[admin] = true;
  }

  function revokeAdminRole(address admin) public onlyOwner {
    admins[admin] = false;
  }
}
