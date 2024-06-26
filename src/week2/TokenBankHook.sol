// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./MyToken.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

contract TokenBank is ITokenReceiver {
    mapping(address => uint256) deposits;

    address public token;

    constructor(address addr) {
        token = addr;
    }

    function deposit(address user, uint256 amount) public {
        MyToken(token).transferFrom(msg.sender, address(this), amount);
        deposits[user] += amount;
    }

    function withdraw(uint256 amount) public {
        MyToken(token).transfer(msg.sender, amount);
        deposits[msg.sender] -= amount;
    }

    // tokensReceived 回调实现
    function tokenReceived(address recipient, uint256 amount, bytes memory extraData) external returns (bool) {
        // 只有合约才能调用
        require(msg.sender == token, "no permission");
        deposits[recipient] += amount;
        return true;
    }

    function balanceOf(address user) public view returns (uint256) {
        return deposits[user];
    }

    // 添加一个函数 permitDeposit 以支持离线签名授权（permit）进行存款
    function permitDeposit(address owner, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        // 先使用 IERC20Permit 接口的 permit 函数给调用方的用户进行授权
        IERC20Permit(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
        // 授权成功后，调用 deposit 函数给 owner 进行存款
        deposit(owner, amount);
    }
}
