pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


import "hardhat/console.sol";

contract NftAuction { 

    address seller;
    uint256 duration;

    uint256 startPrice;

    uint256 startTime;

    bool ended;

    address highestBidder;

    uint256 highestBid;

    address highestBidToken;

    address ntfContract;

    uint256 tokenId;

    address tokenAddress;

    address public admin;



    mapping(address => AggregatorV3Interface) public priceFeeds;

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
        address tokenAddress,
        address _priceFeed
    ) public {
        priceFeeds[tokenAddress] = AggregatorV3Interface(_priceFeed);
    }

      function getChainlinkDataFeedLatestAnswer(address tokenAddress ) public  returns (uint256) {
        AggregatorV3Interface priceFeed = priceFeeds[tokenAddress];
        require(address(priceFeed) != address(0), "Price feed not set");
        priceFeed.version();
        // tt.testLatestRoundData();
        // (
        //     ,
        //     int256 answer,
        //     ,
        //     ,
        // ) = priceFeed.latestRoundData();
        return uint256(1000000000000000000);
    }
    // function placeBidCC(uint256 tokenId, uint256 amount, address _tokenAddress) public payable { 
    // }

    function placeBid(uint256 tokenId, uint256 amount, address _tokenAddress) public payable { 
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


        uint256 highestBidV = highestBid * getChainlinkDataFeedLatestAnswer(highestBidToken); 
        // 转账

        // 转账到当前合约
        if (_tokenAddress != address(0)) {
            bool succ = IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
            require(succ, "transferFrom failed");
        }
        // 退款
        if ( highestBidder != address(0)) {
            // bool succ= IERC20(highestBidToken).transferFrom(address(this), highestBidder, highestBid);
            // require(succ, "return failed");
        } else {
            payable(highestBidder).transfer(highestBid);

        }

        highestBidder = msg.sender;
        highestBid = amount;
        highestBidToken = _tokenAddress;

    }

    function endAuction() public { 
        require(!ended && block.timestamp > startTime + duration, "not end");
        IERC721(ntfContract).transferFrom(address(this), highestBidder, tokenId);
        ended = true;
    }

    function test() public view returns (uint256) { 
        return 123;
    }
}