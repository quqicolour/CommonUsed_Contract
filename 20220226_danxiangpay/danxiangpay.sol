// SPDX-License-Identifier: GPL-3.0
// Solidity 中的单向支付通道
pragma solidity >=0.7.0 <0.8.0;

//导入OpenZeppelin合约 
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/cryptography/ECDSA.sol"; import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/utils/ReentrancyGuard.sol";
// 定义一个叫UniDirectionalPaymentChannel的合约，它继承自ReentrancyGuard
contract UniDirectionalPaymentChannel is ReentrancyGuard { 
using ECDSA for bytes32;

address payable public sender;
address payable public receiver;

constructor(address payable _receiver) payable {
    require(_receiver != address(0), "receiver = zero address");
    sender = msg.sender;
    receiver = _receiver;
}

// 以下四个函数使用私有函数调用是为了重用代码，以这种方式减少gas使用量。
// 创建了4个不同的函数用于哈希并将哈希转换为EthSignedMessageHash
function _getHash(uint _amount) private view returns (bytes32) {
    return keccak256(abi.encodePacked(address(this), _amount));
}

function getHash(uint _amount) external view returns (bytes32) {
    return _getHash(_amount);
}

function _getEthSignedHash(uint _amount) private view returns (bytes32) {
    return _getHash(_amount).toEthSignedMessageHash();
}

function getEthSignedHash(uint _amount) external view returns (bytes32) {
    return _getEthSignedHash(_amount);
}

// 为了从接收方验证哈希，我们需要创建一个逆函数来“取消签名”交易
// 当我们恢复签名时，我们应该获得发送方地址作为结果，这样我们就可以验证金额已经从发送方地址发出
function _verify(uint _amount, bytes memory _sig) private view returns (bool) {
    return _getEthSignedHash(_amount).recover(_sig) == sender;
}

function verify(uint _amount, bytes memory _sig) external view returns (bool) {
    return _verify(_amount, _sig);
}

// 声明了这些函数，以便从一边到另一边签署和恢复信息，我们就可以安全地进行交易了
// 定义一个叫send的external属性函数，传入uint的_amount，bytes的memory的_sig。
function send(uint _amount, bytes memory _sig) external nonReentrant {
    //  验证签名和发送者不等于接收者
    require(msg.sender == receiver, "sender must be different than receiver");
    require(_verify(_amount, _sig), "invalid signature");
    
    (bool sent, ) = receiver.call{value: _amount}("");
    require(sent, "Failed to send Ether");
    selfdestruct(sender);
}
}