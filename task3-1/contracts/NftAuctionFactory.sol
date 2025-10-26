pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {NftAuction} from "./NftAuction.sol";
contract NftAuctionFactory is Initializable, UUPSUpgradeable{

    address public admin;

    address[] public auctions;

    mapping(uint256 => NftAuction) public auctionMap;

    event AuctionCreated(address indexed auctionAddress,uint256 tokenId);

    // constructor() { 
    //     _disableInitializers();
    // }

    function initialize() public initializer { 
        __UUPSUpgradeable_init();
        admin = msg.sender;
    }

    function createAuction(
        uint256 duration,
        uint256 startPrice,
        uint256 startTime,
        address ntfContract,
        uint256 nftTokenId
    ) public returns (address) { 
        
        NftAuction nftAuction = new NftAuction();
        nftAuction.setInit(duration, startPrice, startTime, ntfContract, nftTokenId);
        nftAuction.setPriceFeed(address(0), 0x694AA1769357215DE4FAC081bf1f309aDC325306);

        auctionMap[nftTokenId] = nftAuction;
        auctions.push(address(nftAuction));
        emit AuctionCreated(address(nftAuction), nftTokenId);
        return address(nftAuction);
    }

    function getAuctions() public view returns (address[] memory) { 
        return auctions;
    }


    function getAuction(uint256 index) public view returns (address) { 
        return auctions[index];
    }

     function _authorizeUpgrade(address newImplementation) internal override { 
        require(msg.sender == admin, "only admin can upgrade");
    }
}