const {ethers, deployments} = require("hardhat");

// const {expect} = require("chai");

describe("Auction", async function () { 

    //1、执行部署
    await deployments.fixture(["deploy_nft_auction"]);

    //2、获取TestERC721合约
    const testERC721Proxy = await deployments.get("TestERC721");
    const testERC721 = await ethers.getContractAt("TestERC721", testERC721Proxy.address);

    //3、获取NFTAuction合约
    const nftAuctionProxy = await deployments.get("NftAuction");
    const nftAuction = await ethers.getContractAt("NftAuction", nftAuctionProxy.address);

    //4、获取NFTAuctionFactory合约
    const nftAuctionFactoryProxy = await deployments.get("NftAuctionFactory");
    const nftAuctionFactory = await ethers.getContractAt("NftAuctionFactory", nftAuctionFactoryProxy.address);

    // 进行自测

});