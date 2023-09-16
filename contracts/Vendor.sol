// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BlockBase.sol";

// Learn more about the ERC20 implementation 
// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vendor is Ownable {

  BlockBase blockBaseToken;

  uint256 public priceInEth = 14500000000000;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    blockBaseToken = BlockBase(tokenAddress);
  }


  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "Send ETH to buy some tokens");

    uint256 amountToBuy = (msg.value * 1e18) / priceInEth;

    uint256 vendorBalance = blockBaseToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract has not enough tokens in its balance");

    (bool sent) = blockBaseToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer token to user");

    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has not balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }


  function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
      IERC20 tokenContract = IERC20(_tokenContract);
      tokenContract.transfer(msg.sender, _amount);
  }

  receive() external payable {
    buyTokens();
  }

}