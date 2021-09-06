const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const web3 = new Web3(ganache.provider());
const {
    interface,
    bytecode
} = require("../compile");

let accounts;
let nftCasino;

beforeEach(async () => {
    // Get the account list
    accounts = await web3.eth.getAccounts();

    // Use the first account to deploy the contract
    nftCasino = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({
            data: bytecode,
            arguments: ["Deployed"]
        })
        .send({
            from: accounts[0],
            gas: "1000000",
            gasPrice: '5000000000'
        });
});

describe("NFTCasino", () => {
    it("Contract Deployment", () => {
        assert.ok(nftCasino.options.address);
    });

    it("Contains the default status", async () => {

        /** Check that it contains the status given by the constructor */
        assert.equal(await nftCasino.methods.status().call(), "Deployed");
    });

    it("Can update the status", async () => {

        var status = "Testing...";

        /** Set a status */
        await nftCasino.methods.setStatus(status).send({
            from: accounts[0],
            gas: "1000000",
            gasPrice: '5000000000'
        });

        /** Check that the status has been saved */
        const savedStatus = await nftCasino.methods.status().call();

        assert.equal(savedStatus, status);
    });
});