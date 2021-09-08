const { expect } = require("chai");

var redeploy = true;
var deployedContractAddress;

let nftCasino;
let accounts;

var firstUserNFTContract;
var firstUserNFTID;
var secondUserNFTContract;
var secondUserNFTID;

describe("NFTCasino", function () {

    // Contract deployment
    before(async () => {
        console.log("Getting accounts");
        accounts = await ethers.getSigners();
        console.log("Accounts found, owner will be: " + accounts[0].address);
    
        if(redeploy){
            console.log("Preparing to deploy");
            let NFTCasinoFactory = await ethers.getContractFactory("NFTCasino");
            console.log("Deploying contract...");
            nftCasino = await NFTCasinoFactory.deploy();
        }else{
            console.log("Getting contract");
            const nftCasinoArtifact = await artifacts.readArtifact("NFTCasino");
            nftCasino = await ethers.getContractAt(nftCasinoArtifact.abi, deployedContractAddress, ethers.provider);
        }
        
        await nftCasino.deployed().then(function(instance) {
                console.log("Contract deployed to: " + instance.address);
            });
    });

    // Contract deployment check
    it("Contract Deployment", async function() {
        expect(await nftCasino.getContractOwner()).be.equal(accounts[0].address);
    });

    let depositID;
    let offerID;
    
    // NFT Deposit
    it("NFT Deposit", async function() {
        await nftCasino.connect(accounts[0]).createDeposit(firstUserNFTContract, firstUserNFTID);
        depositID = await nftCasino.connect(accounts[0]).getDepositID(firstUserNFTContract, firstUserNFTID);
        const {nftContract, tokenId, owner, matchPlayed, newOwner} = await nftCasino.connect(accounts[1]).getDepositInfo(depositID);
        expect(owner).be.equal(accounts[0].address);
    });

    // NFT Deposit cancelation
    it("NFT Deposit cancelation", async function() {
        console.log("Cancelling the deposit");
        await nftCasino.connect(accounts[1]).cancelDeposit(depositID);
    });
});