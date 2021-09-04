// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.4.25;

contract NFTCasino {
    string public status;
    
    function NFTCasino(string initialStatus) public {
        status = initialStatus;
    }

    
    function setStatus(string newStatus) public {
        status = newStatus;
    }
}