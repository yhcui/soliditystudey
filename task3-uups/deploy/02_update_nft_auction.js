const {ethers, deployments, upgrades} = require("hardhat");
const fs = require('fs');
const path  = require('path');

module.exports = async ({getNamedAccounts, deployments}) => { 
    // 0、前置工作
    const {save} = deployments;
    const {deployer} = await getNamedAccounts();


    console.log(`__dirname: ${__dirname}`);
    const nftauctionfactoryStorePath = path.resolve(__dirname, "./.cache/NftAuctionProxy.json");
    const storeData = fs.readFileSync(nftauctionfactoryStorePath, "utf-8");
    const {nftAuctionProxyAddress, implAdd, abi} = JSON.parse(storeData);

    // 3、部署 NftAuction
    const nftAuctionV2Factory = await ethers.getContractFactory("NftAuctionV2");

    const nftAuctionProxyV2 = await upgrades.upgradeProxy(nftAuctionProxyAddress, nftAuctionV2Factory, {call:"admin"});

    await nftAuctionProxyV2.waitForDeployment();

    const proxyAddressV2 = await nftAuctionProxyV2.getAddress();

    const abiV2 = (await deployments.getArtifact("NftAuctionV2")).abi;
    
    console.log(`NftAuctionProxyV2: ${proxyAddressV2},nftAuctionProxyAddress:${nftAuctionProxyAddress}`);
    await save("NftAuctionProxyV2", {
        address: proxyAddressV2,
        abi: abiV2
    });

}
module.exports.tags = ["update_nft_auction"];
