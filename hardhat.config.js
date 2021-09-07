require("@nomiclabs/hardhat-waffle");

module.exports = {
    defaultNetwork: "rinkeby",
    networks: {
        hardhat: {
        },
        rinkeby: {
          url: process.env.NFTCASINO_RINKEBY_ENDPOINT,
          accounts: {
            mnemonic: process.env.NFTCASINO_WALLET
          }
        }
      },
      solidity: {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: false,
            runs: 800
          }
        }
      },
      paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
      },
      mocha: {
        timeout: 100000
      }
    };