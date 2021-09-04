const path = require("path");
const fs = require("fs");
const solc = require("solc");

const nftCasinoPath = path.resolve(__dirname, "contracts", "NFTCasino.sol");
const source = fs.readFileSync(nftCasinoPath, "utf8");

module.exports = solc.compile(source, 1).contracts[":NFTCasino"];