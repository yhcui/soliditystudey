const {ethers, deployments, upgrades} = require("hardhat");
const fs = require('fs');
const path  = require('path');

module.exports = async ({getNamedAccounts, deployments}) => { 
    // 0、前置工作
    const {save} = deployments;
    const {deployer} = await getNamedAccounts();

    // 3、部署 NftAuction
    const nftAuctionFactory = await ethers.getContractFactory("NftAuction");
    const nftAuctionProxy = await upgrades.deployProxy(nftAuctionFactory,[],{
        initializer: "initialize",
    });
    await nftAuctionProxy.waitForDeployment();
    const nftAuctionProxyAddress = await nftAuctionProxy.getAddress();
    const implAdd =  await upgrades.erc1967.getImplementationAddress(nftAuctionProxyAddress);

    console.log(`__dirname: ${__dirname}`);
    const nftauctionfactoryStorePath = path.resolve(__dirname, "./.cache/NftAuctionProxy.json");



    fs.writeFileSync(nftauctionfactoryStorePath, JSON.stringify({
        nftAuctionProxyAddress,
        implAdd,
        abi: nftAuctionFactory.interface.format('json')
    }));

    await save("NftAuctionProxy", {
        address: nftAuctionProxyAddress,
        abi: nftAuctionFactory.interface.format('json')
    });

}
module.exports.tags = ["deploy_nft_auction"];
