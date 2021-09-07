async function main() {
    console.log("Getting artifacts together");
    // We get the contract to deploy
    const NFTCasinoContract = await ethers.getContractFactory("NFTCasino");
    console.log("Deploying...");
    const nftCasinoContract = await NFTCasinoContract.deploy("NFTCasino");
  
    console.log("NFTCasino deployed to:", nftCasinoContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });