const { expect } = require("chai");

let nftCasino;
let accounts;

beforeEach(async () => {
    console.log("Getting accounts");
    accounts = await ethers.getSigners();
    console.log("Accounts found, owner will be: " + accounts[0].address);

    console.log("Preparing to deploy");
    let NFTCasino = await ethers.getContractFactory("NFTCasino");
    console.log("Deploying contract...");
    nftCasino = await NFTCasino.deploy();
    
    await nftCasino.deployed();
});

describe("NFTCasino", () => {

    it("Contract Deployment", async function() {
        expect(await nftCasino.getContractOwner()).be.equal(accounts[0].address);
    });
});