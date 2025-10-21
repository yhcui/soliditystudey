const {ethers, deployments,upgrades} = require("hardhat");

const fs = require('fs');

const path = require('path');

module.exports = async ({getNamedAccounts,deployments}) =>{
    const {save} = deployments;
    const {deployer,user1,user2} = await getNamedAccounts();
    // 1、部署TestERC721
    const TestERC721 = await ethers.getContractFactory("TestERC721");
    const testERC = await TestERC721.deploy();
    await testERC.waitForDeployment();
    const testErcAdd = await testERC.getAddress();
    console.log("TestERC721 deployed to:", testErcAdd);

    // const testErcProxy = await deployments.get("TestERC721");
    // const testErcContract = await ethers.getContractAt("TestERC721", testErcProxy.address);
    const tokenId = 1;
    testERC.mint(deployer, tokenId);
    // 2、部署NFTAuction

    const NFTAuction = await ethers.getContractFactory("NftAuction");

    const sellerAddress = deployer; // 假设部署者就是卖家


    const itemContractAddress = testErcAdd; // 实际 NFT 合约地址
    const itemId = tokenId; 
    const durationInSeconds = 3600; // 1小时
    const ethPriceFeedAddress = '0x694AA1769357215DE4FAC081bf1f309aDC325306'; // Chainlink ETH/USD Feed 地址

    // 定义参数数组
    // const initializerArgs = [
    //     sellerAddress,
    //     itemContractAddress,
    //     itemId,
    //     durationInSeconds,
    //     ethPriceFeedAddress
    // ];

    const nftProxy = await upgrades.deployProxy(NFTAuction, [], {initializer: false});

    // const nftProxy = await upgrades.deployProxy(NFTAuction, initializerArgs, {initializer: "initialize"});

    await nftProxy.waitForDeployment();
    const proxyAddress = await nftProxy.getAddress();

    impAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);

    console.log("NFTAuction proxyAddress:", proxyAddress);
    console.log("NFTAuction impAddress:", impAddress);
    // 3、部署NFTAuctionFactory

    const NftAuctionFactory = await ethers.getContractFactory("NftAuctionFactory");
    const nftFactory = await NftAuctionFactory.deploy(impAddress, ethPriceFeedAddress);
    await nftFactory.waitForDeployment();
    const factoryAddress = await nftFactory.getAddress();
    console.log("NFTAuctionFactory deployed to:", factoryAddress);


    //1、保存TestERC721
    const testercstorePath = path.resolve(__dirname, "./.cache/deploy_test_erc721.json");
    fs.writeFileSync(testercstorePath, JSON.stringify({
        testErcAdd,
        abi: TestERC721.interface.format("json"),
    }));

     await save("TestERC721", {
        abi: TestERC721.interface.format("json"),
        address: testErcAdd,
        args:[],
        log: true,
    })


    //2、保存NFTAuction

    const nftstorePath = path.resolve(__dirname, "./.cache/deploy_nft_auction.json");

    fs.writeFileSync(nftstorePath, JSON.stringify({
        proxyAddress,
        impAddress,
        abi: NFTAuction.interface.format("json"),
    }));

    await save("NftAuction", {
        abi: NFTAuction.interface.format("json"),
        address: proxyAddress,
        args:[],
        log: true,
    })

    //3、保存NFTAuctionFactory
    const factorystorePath = path.resolve(__dirname, "./.cache/deploy_nft_auction_factory.json");
    fs.writeFileSync(factorystorePath, JSON.stringify({
        factoryAddress,
        abi: NftAuctionFactory.interface.format("json"),
    }));

     await save("NftAuctionFactory", {
        abi: NftAuctionFactory.interface.format("json"),
        address: factoryAddress,
        args:[],
        log: true,
    })

}

module.exports.tags = ["deploy_nft_auction"];