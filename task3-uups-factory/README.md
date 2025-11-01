# 安装依赖


```shell

npm install @openzeppelin/contracts
npm install @openzeppelin/contracts-upgradeable
npm install @chainlink/contracts
npm install hardhat-deploy
npm install @openzeppelin/hardhat-upgrades
```


# 部署
npx hardhat deploy --network sepolia  --tags deploy_nft_auction

# 升级
npx hardhat deploy --network sepolia  --tags update_nft_auction

# 测试
```shell
npx hardhat test  .\test\auction.js
npx hardhat test  .\test\update.js 

```

# 合约地址
TestERC20 deployed to: 0xc18a4B44307093b7D27719491C299e679B0Ad8e5
TestERC721 deployed to: 0x5c02E3400cB86091c057b8CE60B7BF06a0aFE06C
NftAuctionFactoryProxy deployed to: 0xCD533413bD5805BA047fEBa9A67b46BB09722e3c
NftAuctionFactoryProxy implementation address: 0x2AAC872bEF5829A399aD0956852907eEb00d63dE

NftAuctionV2 deployed to: 0xA7496d2bCF571e64C0A1405d0c0620C680A30989
NftAuctionFactoryProxyV2: 0xCD533413bD5805BA047fEBa9A67b46BB09722e3c