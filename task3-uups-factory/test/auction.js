const {ethers, deployments,upgrades} = require("hardhat");
const {expect} = require("chai");

describe("Test Auction", function () { 
    // beforeEach(async function () {
    //     await main();
    // });

    it("Test Auction", async function () {
       await main();
    });
});

async function main() {
    const [signer,buyer1, buyer2] = await ethers.getSigners();
    signerAddress = await signer.getAddress()
    const provider = ethers.provider;
    const balanceWei = await provider.getBalance(signerAddress);
    // 4. 将 Wei 转换为 Ether 方便阅读
    const balanceEther = ethers.formatEther(balanceWei);
    console.log(`balanceEther: ${balanceEther}`);

    await deployments.fixture(["deploy_nft_auction"]);
    const ZERO_ADDRESS = ethers.ZeroAddress;

    // 部署ERC20
    const TestERC20Factory = await ethers.getContractFactory("TestERC20");
    const TestERC20 = await TestERC20Factory.deploy();
    const TestERC20Contract = await TestERC20.waitForDeployment();
    const MTKERC20Address = await TestERC20Contract.getAddress();
    TestERC20Contract.mint(buyer2, ethers.parseEther("10000000"));


    // 获取聚合工厂
    const aggreagatorV3 = await ethers.getContractFactory("AggreagatorV3");

    const priceFeedEthDeploy = await aggreagatorV3.deploy(ethers.parseEther("1"));
    const priceFeedEth = await priceFeedEthDeploy.waitForDeployment();
    const priceFeedEthAddress = await priceFeedEth.getAddress();
   console.log(`priceFeedEthAddress: ${priceFeedEthAddress}`);

    const version = await priceFeedEth.version();
    console.log(`priceFeedMTK.version: ${version}`);
    // 你的 Solidity 返回变量名是：roundId, _answer, startedAt, updatedAt, answeredInRound
    const { roundId, _answer, startedAt, updatedAt, answeredInRound } = await priceFeedEth.latestRoundData();

    // 然后你可以用新的变量名打印
    console.log(`priceFeedMTK.latestRoundData: ${roundId}, ${_answer}, ${startedAt}, ${updatedAt}, ${answeredInRound}`);

    const priceFeedMTKDeploy = await aggreagatorV3.deploy(ethers.parseEther("10"));
    const priceFeedMTK = await priceFeedMTKDeploy.waitForDeployment();
    const priceFeedMTKAddress = await priceFeedMTK.getAddress();
    console.log(`priceFeedMTKAddress: ${priceFeedMTKAddress}`);

    const manyTokens = [{
        token: ethers.ZeroAddress,
        priceFeed: priceFeedEthAddress,
    },{
        token: MTKERC20Address,
        priceFeed: priceFeedMTKAddress,
    }];

    //获取代理工厂
    const NftAuctionFactoryProxy = await deployments.get("NftAuctionFactoryProxy");
    // const NftAuctionFactoryProxy = await ethers.getContractFactory("NftAuctionFactoryProxy");
    const NftAuctionFactory = await ethers.getContractAt("NftAuctionFactory", NftAuctionFactoryProxy.address);
    const NftAuctionFactoryAddress = await NftAuctionFactory.getAddress();
    const NftAuctionFactoryImp = await upgrades.erc1967.getImplementationAddress(NftAuctionFactoryProxy.address);

    // 获取TestERC721

    const TestERC721Factory = await ethers.getContractFactory("TestERC721");
    const TestERC721Contract = await TestERC721Factory.deploy();
    await TestERC721Contract.waitForDeployment();
    const TestERC721Address = await TestERC721Contract.getAddress();
    
    const tokenId = 1;
    await TestERC721Contract.mint(signer, tokenId);

    const duration = 60 * 1;
    const startPrice = ethers.parseEther("0.1");
    const startTime = 1;
    const ntfContract = TestERC721Address;
    const nftTokenId = tokenId;

    // await nftContract.connect(owner).setApprovalForAll(factoryAddress, true);

    // --- 或者只授权单个 Token ID（如果不想给所有权限）---
    await TestERC721Contract.connect(signer).approve(NftAuctionFactoryAddress, tokenId);

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

    const auctionAddress = await auctionContract.getAddress();
    // 4. 调用新合约上的 test() 函数
    const testValue = await auctionContract.test();

    // 设置预言机
    for (let i = 0; i < manyTokens.length; i++) {
        const {token,priceFeed} = manyTokens[i];
        console.log(`manyTokens[${i}]: ${token}, ${priceFeed}`)
        await auctionContract.setPriceFeed(token, priceFeed);
    }

    //开始拍卖
    let tx = await auctionContract.connect(buyer1).placeBid(1, 0, ethers.ZeroAddress,{value: ethers.parseEther("1")});
    await tx.wait();
    const highestBidder1 = await auctionContract.highestBidder();
    const highestBid1 = await auctionContract.highestBid();
    const highestBidToken1 = await auctionContract.highestBidToken();

    console.log(`highestBidder1: ${highestBidder1},highestBid1: ${highestBid1},highestBidToken1: ${highestBidToken1}`);
    
    // buyer2授权给合同地址可以转账 - TestERC20Contract合约已经给buyer2一批钱了
    await TestERC20Contract.connect(buyer2).approve(auctionAddress, ethers.MaxUint256);
    tx = await auctionContract.connect(buyer2).placeBid(1, ethers.parseEther("5"), MTKERC20Address);
    await tx.wait();

    //结束拍卖
    await auctionContract.connect(signer).endAuction();

    //验证拍卖结果
    const highestBidder = await auctionContract.highestBidder();
    const highestBid = await auctionContract.highestBid();
    console.log(`highestBidder: ${highestBidder}`)
    expect(highestBidder).to.equal(buyer2.address);
    expect(highestBid).to.equal(ethers.parseEther("5"));

    // 验证拍卖所有权
    const owner = await TestERC721Contract.ownerOf(nftTokenId);
    console.log(`owner: ${owner},buyer2.address:${buyer2.address}`)
    expect(owner).to.equal(buyer2.address);
}