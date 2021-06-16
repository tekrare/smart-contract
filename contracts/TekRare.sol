// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract TekRare is ERC1155 {
  address public owner;
  
  constructor (string memory uri) ERC1155(uri) {
    owner = msg.sender;
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  fallback () external payable {}
  
  receive () external payable {}
  
  function getBalance() public view onlyOwner returns (uint) {
    return address(this).balance;
  }
  
  function withdrawBalance() public onlyOwner {
    payable(owner).transfer(getBalance());
  }
}
