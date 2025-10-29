pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract NftAuction is IERC721Receiver { 

    address seller;
    uint256 duration;

    uint256 startPrice;

    uint256 startTime;

    bool ended;

    address public highestBidder;

    uint256 public highestBid;

    address public highestBidToken;

    address ntfContract;

    uint256 public tokenId;

    address tokenAddress;

    address public admin;



    mapping(address => AggregatorV3Interface) public priceFeeds;

    using SafeERC20 for IERC20;

    constructor() { 
    }   

    function setInit(uint256 _duration,
        uint256 _startPrice,
        uint256 _startTime,
        address _nftContractAddress,
        uint256 _tokenId) public { 
        admin = msg.sender;
        seller = msg.sender;
        duration = _duration;
        startPrice = _startPrice;
        startTime = _startTime;
        ended = false;
        highestBidder = address(0);
        highestBid = 0;
        highestBidToken = address(0);
        ntfContract = _nftContractAddress;
        tokenId = _tokenId;
        tokenAddress = address(0);
    }

    function setPriceFeed(
        address _tokenAddress,
        address _priceFeed
    ) public {
        priceFeeds[_tokenAddress] = AggregatorV3Interface(_priceFeed);
    }

      function getChainlinkDataFeedLatestAnswer(address _tokenAddress ) public  returns (uint256) {
        AggregatorV3Interface priceFeed = priceFeeds[_tokenAddress];
        (
            ,
            int256 answer,
            ,
            ,
        ) = priceFeed.latestRoundData();


        return uint256(answer);
    }
    // function placeBidCC(uint256 tokenId, uint256 amount, address _tokenAddress) public payable { 
    // }

    function placeBid(uint256 _tokenId, uint256 amount, address _tokenAddress) public payable {
        require(!ended, "auction ended");
        uint256  payValue;
        if (_tokenAddress != address(0)) {
            payValue =  amount * getChainlinkDataFeedLatestAnswer(_tokenAddress);
        } else {
            amount = msg.value;
            payValue = amount * getChainlinkDataFeedLatestAnswer(_tokenAddress);
        }
        
        // 对比价格
        uint256 startPriceV = startPrice * getChainlinkDataFeedLatestAnswer(tokenAddress);

        require(payValue > startPriceV, "must greate startPrice");
        if (highestBid >0 ) {
            uint256 highestBidV = highestBid * getChainlinkDataFeedLatestAnswer(highestBidToken); 
            require(payValue > highestBidV, "must greate highestBidV");
        }
        

        // 转账到当前合约
        if (_tokenAddress != address(0)) {
            bool succ = IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
            require(succ, "transferFrom failed");
        }
        if (highestBid > 0) {
            // 退款
            if ( highestBidToken == address(0)) {
                payable(highestBidder).transfer(highestBid);
            } else {
                // bool succ= IERC20(highestBidToken).transferFrom(address(this), highestBidder, highestBid);
                // require(succ, "transferFrom failed");
                IERC20(highestBidToken).transfer(highestBidder, highestBid);

            }
        }
        

        highestBidder = msg.sender;
        highestBid = amount;
        highestBidToken = _tokenAddress;
        tokenId = _tokenId;

    }

    function endAuction() public { 
        require(!ended && block.timestamp > startTime + duration, "not end");
        // IERC721(ntfContract).transferFrom(address(this), highestBidder, tokenId);
        IERC721(ntfContract).safeTransferFrom(
            address(this),
            highestBidder,
            tokenId
        );
        ended = true;
    }

    function test() public view returns (uint256) { 
        return 123;
    }


    // 实现 ERC721 安全接收回调函数
    // 这是一个特殊的函数，必须由 NFT 合约调用
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override returns (bytes4) {
        // 确保只有 NFT 合约才能调用此函数（可选的安全检查）
        // require(msg.sender == address(nftContract), "Invalid caller"); 
        
        // 由于您的合约只需要持有 NFT，直接返回魔术值即可
        return this.onERC721Received.selector;
    }
}