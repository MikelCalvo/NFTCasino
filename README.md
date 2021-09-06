# :slot_machine: NFTCasino :slot_machine:
Sample project I'm coding while learning Solidity.

The goal is to create a series of smart contracts that allows a users to bet one NFT at 50% odds against another user.
Winner gets both NFTs.

Feel free to contribute to this project by forking it and sending me a pull request.

Logic works as follows:
- User A deposits NFT into the contract.
- User B deposits NFT into the contract against user A.
- User A accepts the match offer sent by user B.
    - When user A accepts the offer, the contract will randomly select a winner.
- Winner gets both NFTs.

## :scroll: TODO:
- [x] Create the base functions for the contract
- [ ] Generate the random winner with a Chainlink Oracle
- [ ] Allow the withdrawal of accidental NFT deposits
- [ ] Create a deadline for the abandoned NFTs to be withdrawn, if the deadline is reached the NFTs become withdrawable by the contract owner
- [ ] Allow the contract to automatically swap half of ETH profits for LINK if the contract is running low, so we can call the oracle again in the future
- [ ] Allow the loser to mint an NFT to remember the loss
- [ ] Allow external users to bet ETH on the output of a match
- [ ] Allow external users to withdraw their ETH profits