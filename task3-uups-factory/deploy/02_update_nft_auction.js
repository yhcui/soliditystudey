const {ethers, deployments, upgrades} = require("hardhat");
const fs = require('fs');
const path  = require('path');

module.exports = async ({getNamedAccounts, deployments}) => { 
    // 0、前置工作
    const {save} = deployments;
    const {deployer} = await getNamedAccounts();

    const storePath = path.resolve(__dirname, "./.cache/NftAuctionFactory.json");
    const storeDate = JSON.parse(fs.readFileSync(storePath));
    const {NftAuctionFactoryProxyAddress, NftAuctionFactoryContractAddress,abi} =  storeDate;


    const NftAuctionFactoryV2 = await ethers.getContractFactory("NftAuctionFactoryV2");

    const NftAuctionFactoryProxV2 = await upgrades.upgradeProxy(NftAuctionFactoryProxyAddress, NftAuctionFactoryV2);
    await NftAuctionFactoryProxV2.waitForDeployment();
    const NftAuctionFactoryProxV2Addr = await NftAuctionFactoryProxV2.getAddress();

  

    await save("NftAuctionFactoryProxyV2", {
        address: NftAuctionFactoryProxV2Addr,
        abi
    });

}
module.exports.tags = ["update_nft_auction"];
