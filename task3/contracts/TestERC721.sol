pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestERC721 is ERC721Enumerable, Ownable {


    string private _tokenURI;
    constructor() ERC721("TestERC721", "T721") Ownable(msg.sender) {

    }
    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }

    function tokenURL(uint256 tokenId) public view returns (string memory) {
        return tokenURI(tokenId);
    }

    function setTokenURI(string memory newTokenURI) public {
        _tokenURI = newTokenURI;
    }
} 