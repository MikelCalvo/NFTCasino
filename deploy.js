const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");
const {
    interface,
    bytecode
} = require("./compile");

const provider = new HDWalletProvider({
    mnemonic: process.env.NFTCASINO_WALLET,
    providerOrUrl: process.env.NFTCASINO_ENDPOINT
});

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log("Attempting to deploy from account", accounts[0]);
    const result = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({
            data: bytecode,
            arguments: ["Deployed"]
        })
        .send({
            from: accounts[0],
            gas: "1000000",
            gasPrice: '5000000000'
        });
    console.log("Contract deployed to", result.options.address);
};
deploy();