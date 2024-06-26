pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarket is IERC721Receiver, Initializable, UUPSUpgradeable, OwnableUpgradeable {
    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => address) public tokenSeller;
    address public token;
    address public nftToken;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // 代理合约不会使用构造函数（链上编译后没有ABI没有构造函数了）
        _disableInitializers();
    }

    // 确保初始化方法只运行一次，以防止意外重新初始化
    function initialize(address initialOwner_, address token_, address nftToken_) public initializer {
        // 开启了增强的授权机制
        __Ownable_init(initialOwner_);
        // 开启可升级功能
        __UUPSUpgradeable_init();

        // 初始化 erc20 和 erc721
        token = token_;
        nftToken = nftToken_;
    }

    // 确保了安全的合约升级，只允许所有者授权新的合约版本
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }

    // approve(address to, uint256 tokenId) first
    function list(uint256 tokenId, uint256 amount) public {
        IERC721(nftToken).safeTransferFrom(msg.sender, address(this), tokenId, "");
        tokenIdPrice[tokenId] = amount;
        tokenSeller[tokenId] = msg.sender;
    }

    function buy(uint256 tokenId, uint256 amount) external {
        require(amount >= tokenIdPrice[tokenId], "low price");

        require(IERC721(nftToken).ownerOf(tokenId) == address(this), "aleady selled");

        IERC20(token).transferFrom(msg.sender, tokenSeller[tokenId], tokenIdPrice[tokenId]);
        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
    }
}
