require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy")
require("@openzeppelin/hardhat-upgrades")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts: {
    deployer: 0,
  },
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/换成自己的",
      accounts: ["小狐狸私钥"],
      chainId: 11155111,
    },
  },
};
