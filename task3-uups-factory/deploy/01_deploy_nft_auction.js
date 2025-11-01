const {ethers, deployments, upgrades} = require("hardhat");
const fs = require('fs');
const path  = require('path');

module.exports = async ({getNamedAccounts, deployments}) => { 
    // 0、前置工作
    const {save} = deployments;
    const {deployer} = await getNamedAccounts();

    // 1、部署 TestERC20
    const TestERC20Factory = await ethers.getContractFactory("TestERC20");
    const TestERC20Contract = await TestERC20Factory.deploy();
    await TestERC20Contract.waitForDeployment();
    const TestERC20Address = await TestERC20Contract.getAddress();
    console.log(`TestERC20 deployed to: ${TestERC20Address}`);

    //    2、部署 TestERC721
    const TestERC721Factory = await ethers.getContractFactory("TestERC721");
    const TestERC721Contract = await TestERC721Factory.deploy();
    await TestERC721Contract.waitForDeployment();
    const TestERC721Address = await TestERC721Contract.getAddress();
    console.log(`TestERC721 deployed to: ${TestERC721Address}`);
    const tokenId = 1;
    await TestERC721Contract.mint(deployer, tokenId);

    // 3、部署 NftAuction
    const NftAuctionFactory = await ethers.getContractFactory("NftAuction");
    const NftAuctionContract = await NftAuctionFactory.deploy();
    await NftAuctionContract.waitForDeployment();
    const NftAuctionAddress = await NftAuctionContract.getAddress();
    // console.log(`NftAuction deployed to: ${NftAuctionAddress}`);


    // 4、部署 NftAuctionFactory
    const NftAuctionFactoryFactory= await ethers.getContractFactory("NftAuctionFactory");
    const NftAuctionFactoryProxy = await upgrades.deployProxy(NftAuctionFactoryFactory, [], { initializer: 'initialize' })
    await NftAuctionFactoryProxy.waitForDeployment();
    const NftAuctionFactoryProxyAddress = await NftAuctionFactoryProxy.getAddress();
    console.log(`NftAuctionFactoryProxy deployed to: ${NftAuctionFactoryProxyAddress}`);
    const NftAuctionFactoryContractAddress = await upgrades.erc1967.getImplementationAddress(NftAuctionFactoryProxyAddress);
    console.log(`NftAuctionFactoryProxy implementation address: ${NftAuctionFactoryContractAddress}`);


    // 保存 TestERC20

    const testerc20StorePath = path.resolve(__dirname, "./.cache/TestERC20.json");
    fs.writeFileSync(testerc20StorePath, JSON.stringify({
        address: TestERC20Address,
        abi: TestERC20Contract.interface.format('json')
    }));

    // 保存 TestERC721
    const testerc721StorePath = path.resolve(__dirname, "./.cache/TestERC721.json");
    fs.writeFileSync(testerc721StorePath, JSON.stringify({
        address: TestERC721Address,
        abi: TestERC721Contract.interface.format('json')
    }));

    await save("TestERC721", {
        address: TestERC721Address,
        abi: TestERC721Contract.interface.format('json')
    });

    // 保存 NftAuction
    const NftauctionStorePath = path.resolve(__dirname, "./.cache/NftAuction.json");
    fs.writeFileSync(NftauctionStorePath, JSON.stringify({
        address: NftAuctionAddress,
        abi: NftAuctionContract.interface.format('json')
    }));

    // 保存 NftAuctionFactory
    const nftauctionfactoryStorePath = path.resolve(__dirname, "./.cache/NftAuctionFactory.json");
    fs.writeFileSync(nftauctionfactoryStorePath, JSON.stringify({
        NftAuctionFactoryProxyAddress,
        NftAuctionFactoryContractAddress,
        abi: NftAuctionFactoryFactory.interface.format('json')
    }));

    await save("NftAuctionFactoryProxy", {
        address: NftAuctionFactoryProxyAddress,
        abi: NftAuctionFactoryFactory.interface.format('json')
    });

}
module.exports.tags = ["deploy_nft_auction"];
