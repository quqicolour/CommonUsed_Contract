pragma solidity ^0.4.19;
import "./ownable.sol";
// 写一个函数来从合约中提现以太
contract GetPaid is Ownable {
  function withdraw() external onlyOwner {
    owner.transfer(this.balance);
  }
}