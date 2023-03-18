// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Auction {
    // uint public id;
    string public title;
    string public description;

    uint public endTime;

    address payable public seller;
    address payable public highestBidder;
    uint public highestBid;

    // TODO: deposit functionality

    constructor(uint256 _startingPrice, string memory _title, string memory _description, uint _duration) {
        seller = payable(msg.sender);
        highestBid = _startingPrice;
        title = _title;
        description = _description;
        endTime = block.timestamp + _duration;
    }

    /// The function cannot be called at the current state.
    error InvalidState();
    /// Only the buyer is allowed to perform this action
    error OnlyBuyer();    /// Only the seller is allowed to perform this action

    error OnlySeller();
    /// Bidding only allowed when value is higher than current highest bid
    error InvalidBid();

    modifier onlyBuyer() {
        if(msg.sender != highestBidder) {
            revert OnlyBuyer();
        }
        _;
    }

    modifier onlySeller() {
        if(msg.sender != seller) {
            revert OnlySeller();
        }
        _;
    }

    modifier onlyDuringOpen() {
        if(block.timestamp > endTime) {
            revert InvalidState();
        }
        _;
    }

    modifier onlyDuringClosed() {
        if(block.timestamp <= endTime) {
            revert InvalidState();
        }
        _;
    }

    // returns the state of the contract
    // TODO: do we need this? to be used in the front-end
    function getStatus() public view returns (string memory){
        if(block.timestamp <= endTime) {
            return "open";
        } else {
        return "closed";
        }
    }

    function bid() public onlyDuringOpen payable {
        if(msg.value <= highestBid) {
            revert InvalidBid();
        }

        if(highestBidder != address(0)) {
            highestBidder.transfer(highestBid);
        }

        highestBidder = payable(msg.sender);
        highestBid = msg.value;
    }

    // seller closed the auction to start the transaction with the buyer
    function finalize() external onlySeller {
        seller.transfer(address(this).balance);
        endTime = 0;
    }

    // to finish the auction and not accept the bid
    function abort() external onlySeller {
        highestBidder.transfer(address(this).balance);
        endTime = 0;
    }
}
