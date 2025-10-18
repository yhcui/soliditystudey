// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MyNft is ERC721URIStorage, Ownable{

    uint256 private _tokenIdCounter = 1;

    constructor(string memory name,string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {
        
    }

    function mintNFT(address to, string memory tokenURL) public onlyOwner returns(uint256) {

        uint256 newTokenId = _tokenIdCounter;
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURL);
        _tokenIdCounter++;
        return newTokenId;
        
    }
}