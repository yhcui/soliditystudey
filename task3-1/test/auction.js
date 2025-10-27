const {ethers, deployments,upgrades} = require("hardhat");
const {expect} = require("chai");

describe("Test Auction", function () { 
    it("NFT", async function () { 
        await main();
    });
});

async function main() { 
    const [signer,buyer] = await ethers.getSigners();
    await deployments.fixture(["deploy_nft_auction"]);
    const ZERO_ADDRESS = ethers.ZeroAddress;

    // 部署ERC20
    const TestERC20Factory = await ethers.getContractFactory("TestERC20");
    const TestERC20 = await TestERC20Factory.deploy();
    const TestERC20Contract = await TestERC20.waitForDeployment();
    const MTKERC20Address = await TestERC20Contract.getAddress();


    // 获取聚合工厂
    const aggreagatorV3 = await ethers.getContractFactory("AggreagatorV3");

    const priceFeedEthDeploy = await aggreagatorV3.deploy(ethers.parseEther("10000"));
    const priceFeedEth = await priceFeedEthDeploy.waitForDeployment();
    const priceFeedEthAddress = await priceFeedEth.getAddress();

    const priceFeedMTKDeploy = await aggreagatorV3.deploy(ethers.parseEther("5"));
    const priceFeedMTK = await priceFeedMTKDeploy.waitForDeployment();
    const priceFeedMTKAddress = await priceFeedMTK.getAddress();


    const manyTokens = [{
        token: ethers.ZeroAddress,
        priceFeed: priceFeedEthAddress,
    },{
        token: MTKERC20Address,
        priceFeed: priceFeedMTKAddress,
    }];

    //获取代理工厂
    const NftAuctionFactoryProxy = await deployments.get("NftAuctionFactoryProxy");
    console.info("NftAuctionFactoryProxy.address:" + NftAuctionFactoryProxy.address);
    const NftAuctionFactory = await ethers.getContractAt("NftAuctionFactory", NftAuctionFactoryProxy.address);
    // const NftAuctionFactoryAdd = await NftAuctionFactory.getAddress();
    const NftAuctionFactoryImp = await upgrades.erc1967.getImplementationAddress(NftAuctionFactoryProxy.address);
    console.info("NftAuctionFactoryImp:" + NftAuctionFactoryImp);

    // 获取TestERC721

    const TestERC721Factory = await ethers.getContractFactory("TestERC721");
    const TestERC721Contract = await TestERC721Factory.deploy();
    await TestERC721Contract.waitForDeployment();
    const TestERC721Address = await TestERC721Contract.getAddress();
    console.log(`TestERC721 deployed to: ${TestERC721Address}`);
    const tokenId = 1;
    await TestERC721Contract.mint(signer, tokenId);

    const duration = 60 * 1;
    const startPrice = BigInt(1) * (BigInt(10) ** BigInt(18));
    const startTime = 1;
    const ntfContract = TestERC721Address;
    const nftTokenId = tokenId;

    const auctionContractTx = await NftAuctionFactory.createAuction(
        duration,
        startPrice,
        startTime,
        ntfContract,
        nftTokenId);
    const receipt = await auctionContractTx.wait();

    const eventSignature = "AuctionCreated(address,uint256)";
    const eventInterface = NftAuctionFactory.interface.getEvent(eventSignature);
    let newAuctionAddress;

    for (const log of receipt.logs) {
        try {
            const parsedLog = NftAuctionFactory.interface.parseLog(log);
            if (parsedLog && parsedLog.name === "AuctionCreated") {
                newAuctionAddress = parsedLog.args[0];
                break;
            }
        } catch (e) {

        }
    }
    if (!newAuctionAddress) {
        throw new Error("未找到 AuctionCreated 事件，无法获取新合约地址。");
    }

    // 3. 使用新地址和 NftAuction 的 ABI 创建合约实例
    const auctionContract = await ethers.getContractAt(
        "NftAuction", 
        newAuctionAddress
    );
    // 4. 调用新合约上的 test() 函数
    const testValue = await auctionContract.test();

    // 设置预言机
    for (let i = 0; i < manyTokens.length; i++) {
        const {tokenAddress,_priceFeed} = manyTokens[i];
        auctionContract.setPriceFeed(tokenAddress, _priceFeed);
    }

    console.log(`新拍卖合约地址: ${newAuctionAddress}`);
    console.log(`test() 结果: ${testValue}`);

    //开始拍卖


}