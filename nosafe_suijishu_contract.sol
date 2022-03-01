pragma solidity ^0.4.19;
// 生成一个0到100的随机数:
// 这个方法首先拿到 now 的时间戳、 msg.sender、 以及一个自增数 nonce 
// （一个仅会被使用一次的数，这样我们就不会对相同的输入值调用一次以上哈希函数了）。
// 然后利用 keccak 把输入的值转变为一个哈希值, 再将哈希值转换为 uint, 
// 然后利用 % 100 来取最后两位, 就生成了一个0到100之间随机数了。
contract noSafeRandom{
uint randNonce = 0;
uint random = uint(keccak256(now, msg.sender, randNonce)) % 100;
randNonce++;
uint random2 = uint(keccak256(now, msg.sender, randNonce)) % 100;
}