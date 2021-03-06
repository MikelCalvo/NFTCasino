// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTCasino {

    address payable contractOwner;

    mapping (uint256 => NFTDeposit) nftDeposits;
    mapping (uint256 => NFTOffer) nftOffers;

    /** General Analytics */
    uint256 public currrentDepositsCount = 0;
    uint256 private totalDepositsCount = 0;
    uint256 public currentOffersCount = 0;
    uint256 private totalOffersCount = 0;
    uint256 private totalBetsCount = 0;
    uint256 private pendingNFTsToWithdrawCount = 0;
    uint256 private totalContractProfits = 0;

    /** Contract deployer will be the owner who can withdraw the profits */
    constructor() {
        contractOwner = payable(msg.sender);
    }

    /** The first wallet to deposit an NFT, it will have to wait for an offer */
    struct NFTDeposit {
        address nftContract;
        uint256 tokenId;
        address owner;
        bool matchPlayed;
        address newOwner;
    }

    /** An offer to start a game with a previously deposited NFT */
    struct NFTOffer {
        address nftContract;
        uint256 tokenId;
        address owner;
        uint256 toDepositID;
        bool matchPlayed;
        address newOwner;
    }

    /** Create a deposit */
    function createDeposit(address nftContract, uint256 tokenId) external returns (uint256 _depositID) {
        IERC721 nftContractInstance = IERC721(nftContract);

        // Security checks
        require(nftContractInstance.ownerOf(tokenId) == msg.sender, "Only the NFT owner can create a deposit");
        require(nftContractInstance.getApproved(tokenId) == address(this) || nftContractInstance.isApprovedForAll(msg.sender, address(this)), "NFT must be approved to be deposited");

        // NFT transfer from owner to contract
        nftContractInstance.safeTransferFrom(msg.sender, address(this), tokenId);
        
        // NFTDeposit creation
        uint256 depositID = uint256(keccak256(abi.encode(nftContract, tokenId)));
        nftDeposits[depositID] = NFTDeposit({
            nftContract: address(nftContract),
            tokenId: tokenId,
            owner: msg.sender,
            matchPlayed: false,
            newOwner: address(0)
        });

        currrentDepositsCount += 1;
        totalDepositsCount += 1;
        return _depositID;
    }

    /** Cancel a deposit & withdraw the NFT */
    function cancelDeposit(uint256 depositID) external {
        NFTDeposit storage details = nftDeposits[depositID];
        IERC721 nftContractInstance = IERC721(details.nftContract);

        // Security checks
        require(details.matchPlayed == false, "NFT already gambled");
        require(msg.sender == details.owner, "Only the owner can cancel the deposit");

        // NFT withdrawal
        nftContractInstance.safeTransferFrom(address(this), details.owner, details.tokenId);

        // NFTDeposit object removal
        delete nftDeposits[depositID];
        currrentDepositsCount -= 1;
    }

    /** Get the info about a deposit */
    function getDepositInfo(uint256 depositID) external view returns (address, uint256, address, bool, address) {
        NFTDeposit storage details = nftDeposits[depositID];
        return (details.nftContract, details.tokenId, details.owner, details.matchPlayed, details.newOwner);
    }

    /** Get deposit ID */
    function getDepositID(address depositedNFTContract, uint256 depositedTokenId) external pure returns (uint256) {
        return uint256(keccak256(abi.encode(depositedNFTContract, depositedTokenId)));
    }

    /** Create an offer */
    function createOffer(address nftContract, uint256 tokenId, uint256 toDepositID) external returns (uint256 _offerID) {
        IERC721 nftContractInstance = IERC721(nftContract);

        // Security checks
        require(nftContractInstance.ownerOf(tokenId) == msg.sender, "Only the NFT owner can create an offer");
        require(nftContractInstance.getApproved(tokenId) == address(this) || nftContractInstance.isApprovedForAll(msg.sender, address(this)), "NFT must be approved to be offered");

        // NFT transfer from owner to contract
        nftContractInstance.safeTransferFrom(msg.sender, address(this), tokenId);

        // NFTOffer creation
        uint256 offerID = uint256(keccak256(abi.encode(nftContract, tokenId)));
        nftOffers[offerID] = NFTOffer({
            nftContract: nftContract,
            tokenId: tokenId,
            owner: msg.sender,
            toDepositID: toDepositID,
            matchPlayed: false,
            newOwner: address(0)
        });

        currentOffersCount += 1;
        totalOffersCount += 1;
        return _offerID;
    }

    /** Cancel an offer & withdraw the NFT */
    function cancelOffer(uint256 offerID) external {
        NFTOffer storage details = nftOffers[offerID];
        IERC721 nftContractInstance = IERC721(details.nftContract);

        //Security checks
        require(details.matchPlayed == false, "NFT already gambled");
        require(msg.sender == details.owner, "Only the owner can cancel the offer");

        // NFT withdrawal
        nftContractInstance.safeTransferFrom(address(this), details.owner, details.tokenId);

        // NFTOffer object removal
        delete nftOffers[offerID];
        currentOffersCount -= 1;
    }

    /** Get the info about an offer */
    function getOfferInfo(uint256 offerID) external view returns (address, uint256, address, uint256, bool, address) {
        NFTOffer storage details = nftOffers[offerID];
        return (details.nftContract, details.tokenId, details.owner, details.toDepositID, details.matchPlayed, details.newOwner);
    }

    /** Get offer ID */
    function getOfferID(address offeredNFTContract, uint256 offeredTokenId) external pure returns (uint256) {
        return uint256(keccak256(abi.encode(offeredNFTContract, offeredTokenId)));
    }

    /** Accept an offer & randomly select a winner */
    function acceptOffer(uint256 depositID, uint256 offerID) external {
        NFTDeposit storage depositDetails = nftDeposits[depositID];
        NFTOffer storage offerDetails = nftOffers[offerID];

        // Security checks
        require(depositDetails.matchPlayed == false, "NFT already gambled");
        require(nftDeposits[depositID].owner == msg.sender, "Only the owner can accept the offer");

        // TODO: Random Winner Selection using Oracles
        uint(blockhash(block.number-1))%2 == 0 ? depositDetails.newOwner = offerDetails.owner : offerDetails.newOwner = depositDetails.owner;
        depositDetails.matchPlayed = true;
        offerDetails.matchPlayed = true;

        totalBetsCount += 1;
        pendingNFTsToWithdrawCount += 2;
    }

    /** Withdraw both NFTs & pay the fee to the contract owner */
    function withdrawPrize(uint256 depositID, uint256 offerID) external payable {
        NFTDeposit storage depositDetails = nftDeposits[depositID];
        NFTOffer storage offerDetails = nftOffers[offerID];

        IERC721 depositNFTContractInstance = IERC721(depositDetails.nftContract);
        IERC721 offerNFTContractInstance = IERC721(offerDetails.nftContract);

        // Security checks
        require(msg.value >= .001 ether, "You must pay at least 0.001 ether");
        require(depositDetails.newOwner == msg.sender, "You can't withdraw the NFT");
        require(offerDetails.newOwner == msg.sender, "You can't withdraw the NFT");

        // NFTs transfer from contract to owner
        depositNFTContractInstance.safeTransferFrom(address(this), msg.sender, depositDetails.tokenId);
        offerNFTContractInstance.safeTransferFrom(address(this), msg.sender, offerDetails.tokenId);

        pendingNFTsToWithdrawCount -= 2;
        totalContractProfits += msg.value;
    }

    /** Allow the contract owner to withdraw all the ETH profits */
    function withdrawContractProfits() external onlyContractOwner {
        // Profits transfer from contract to owner
        contractOwner.transfer(address(this).balance);
    }

    /** Only contractOwner modifier */
    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can withdraw profits");
        _;
    }

    /** Interface required to handle NFT deposits */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        //TODO: Accidental NFT Transfer withdraw method
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    /** Get the contract owner address */
    function getContractOwner() public view returns (address) {
        return contractOwner;
    }

    /** General data about the contract */
    function getAnalytics() public view onlyContractOwner returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return (currrentDepositsCount, totalDepositsCount, currentOffersCount, totalOffersCount, totalBetsCount, pendingNFTsToWithdrawCount, totalContractProfits);
    }
}