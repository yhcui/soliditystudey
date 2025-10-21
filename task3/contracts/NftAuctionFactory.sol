pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./NftAuction.sol";

contract NftAuctionFactory { 

    address public immutable auctionImplementation;

    address[] public allAuctions;

    mapping(address => mapping(uint256 => address)) public auctions;

    // Chainlink ETH/USD 价格 Feed 地址
    address public immutable ethPriceFeed;

    event AuctionCreated(
        address indexed seller, 
        address indexed auctionProxy, 
        address itemContract, 
        uint256 itemId);

    constructor(address _auctionImplementation, address _ethPriceFeed) {
        auctionImplementation = _auctionImplementation;
        ethPriceFeed = _ethPriceFeed;
    }

    /**
     * 创建一个新的可升级拍卖合约实例 (UUPS 代理)
     * 需要 NFT 卖家先将 NFT 授权给 AuctionFactory
     * @param _itemContract 拍卖物品的合约地址 (ERC721)
     * @param _itemId 拍卖物品的Token ID
     * @param _duration 拍卖持续时间（秒）
     * @return newAuctionAddress 新创建的拍卖代理合约地址
     */
    function createAuction(address _itemContract, uint256 _itemId,uint256 _duration) public returns (address) {
        require(auctions[_itemContract][_itemId] == address(0), "NFT has already been auctioned");

        bytes memory data = abi.encodeWithSelector(NftAuction.initialize.selector, _itemContract, _itemId, _duration, ethPriceFeed);

        IERC721(_itemContract).transferFrom(msg.sender, address(this), _itemId);

        ERC1967Proxy newProxy = new ERC1967Proxy(auctionImplementation, "");

        address newAuctionAddress = address(newProxy);

        IERC721(_itemContract).approve(newAuctionAddress, _itemId);

        auctions[_itemContract][_itemId] = newAuctionAddress;

        allAuctions.push(newAuctionAddress);

        emit AuctionCreated(msg.sender, newAuctionAddress, _itemContract, _itemId);
    }

function allAuctionsLength() public view returns (uint256) {
        return allAuctions.length;
    }

    function getAllAuctions() public view returns (address[] memory) {
        return allAuctions;
    }

}