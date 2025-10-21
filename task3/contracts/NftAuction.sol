pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract NftAuction is Initializable, OwnableUpgradeable ,UUPSUpgradeable {

    address seller;

    uint256 startPrices;




    uint256 auctionEndTime;
    bool ended;

    address highestBidder;
    uint256 highestBid;
    address highestBidToken;



    address nftContract;
    uint256 tokenId;
    address tokenAddress;

    mapping(address => AggregatorV3Interface) public priceFeeds;

    AggregatorV3Interface  priceETHFeed;

    event AuctionEnded(address indexed winner, uint256 highestBid, address finalBidToken);


    // constructor() {
    //     _disableInitializers();
    // }

    function initialize(address _seller, 
                        address _itemContract,
                        uint256 _itemId,
                        uint256 _duration,
                        address _ethPriceFeed) public initializer {
        // __UUPSUpgradeable_init();
        __Ownable_init(msg.sender);

        __UUPSUpgradeable_init();

        seller = _seller;

        nftContract = _itemContract;

        tokenId = _itemId;

        auctionEndTime = block.timestamp + _duration;

        priceETHFeed = AggregatorV3Interface(_ethPriceFeed);

    }
    

   /**
     * @notice 允许设置 ERC20 代币的价格 Feed 地址
     * @dev 只能由管理员（Owner）设置
     */
    function setPriceFeed(address tokenAddress, address _priceFeed) public  onlyOwner {
        // priceETHFeed = AggregatorV3Interface(_priceFeed);
        priceFeeds[tokenAddress] =  AggregatorV3Interface(_priceFeed);
    }
 

    function getChainlinkDataFeedLatestAnswer(address tokenAddress) public view returns (int) {
        AggregatorV3Interface priceETHFeed = priceFeeds[tokenAddress];
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceETHFeed.latestRoundData();
        return answer;
    }

    function placeBid(address _tokenAddress, uint256 amount) public payable { 

        require(block.timestamp < auctionEndTime, "Auction has already ended");
        require(amount > 0, "Bid amount must be greater than 0");
        require(amount > startPrices , "Bid amount must be greater than start price");

        uint256 payvalue = getPrice(_tokenAddress, amount);

        uint256 hh = getPrice(highestBidToken, highestBid);

        require(payvalue > hh, "amount must be greater than highest bid");
        

        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);

        if (highestBidToken == address(0)) {
            (bool sucess,) = payable(highestBidder).call{value: highestBid}("");
            require(sucess, "Failed to send Ether");
        } else {
            IERC20(highestBidToken).transfer(highestBidder, highestBid);
        }

        highestBidder = msg.sender;
        highestBid = amount;
        highestBidToken = _tokenAddress;

    }

      function getPrice(address tokenAddress, uint256 _amount) public view returns (uint256) {

        AggregatorV3Interface priceETHFeed;

        if (tokenAddress == address(0)) {
            priceETHFeed = priceETHFeed;
        } else {
            priceETHFeed = priceFeeds[tokenAddress];
        }

        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceETHFeed.latestRoundData();
        return uint256(answer) * _amount;
    }

    function endAuction() public {

        ended = true;

        IERC721(nftContract).safeTransferFrom(address(this), highestBidder, tokenId);
        if (highestBidToken == address(0)) {
            (bool success,) = payable(seller).call{value: highestBid}("");                
            // (bool success, ) = payable(seller).call{value: highestBid}("");
            require(success, "Failed to send Ether");
        } else {
            IERC20(highestBidToken).transfer(seller, highestBid);
        }

        emit AuctionEnded(highestBidder, highestBid, highestBidToken);

    }


    function _authorizeUpgrade(address newImplementation) internal  override {

    }


}