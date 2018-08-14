pragma solidity ^0.4.22;

contract SimpleAuction {
    address public beneficiary;
    uint public auctionEnd;
    bool ended;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(address _beneficiary, uint _biddingTime) public {
        beneficiary = _beneficiary;
        auctionEnd = now + _biddingTime;
    }

    function bid() public payable {
        require(
            now <= auctionEnd,
            "The auction has already ended."
        );
        require(
            msg.value > highestBid,
            "There is already a higher bid."
        );

        if (highestBid > 0) {
            pendingReturns[msg.sender] += msg.value;
            highestBidder = msg.sender;
            highestBid = msg.value;
        }

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];

        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(
            now > auctionEnd,
            "Auction now ended yet."
        );
        require(
            !ended,
            "Auction has already been cancelled"
        );

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}
