pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {NftAuction} from "./NftAuction.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NftAuctionFactory is Initializable, UUPSUpgradeable, IERC721Receiver{

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