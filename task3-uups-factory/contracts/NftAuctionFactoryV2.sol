pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {NftAuctionV2} from "./NftAuctionV2.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract NftAuctionFactoryV2 is Initializable, UUPSUpgradeable{

    address public admin;

    address[] public auctions;

    mapping(uint256 => NftAuctionV2) public auctionMap;

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
        
        NftAuctionV2 nftAuction = new NftAuctionV2();
        nftAuction.setInit(duration, startPrice, startTime, ntfContract, nftTokenId);

        auctionMap[nftTokenId] = nftAuction;
        auctions.push(address(nftAuction));

        // 合约地址先将合约中的token从msg.sender中转给拍卖合约中
        IERC721(ntfContract).safeTransferFrom(msg.sender, address(nftAuction), nftTokenId);

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