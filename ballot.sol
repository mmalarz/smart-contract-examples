pragma experimental ABIEncoderV2;
pragma solidity ^0.4.25;

contract Ballot {
    struct Voter {
        uint weight;
        uint[] vote;
        bool voted;
        address delegate;
    }

    struct Proposal {
        string name;
        uint votes;
    }

    address public chairman;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    constructor(string[] proposalNames) public {
        chairman = msg.sender;
        voters[chairman].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(
                Proposal({
                    name : proposalNames[i],
                    votes : 0
                })
            );
        }
    }

    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairman,
            "Only chairman can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(
            voters[voter].weight == 0,
            "The voter already has right to vote."
        );
        voters[voter].weight = 1;
    }

    function delegate(address delegateToAddress) public {
        address delegateFromAddress = msg.sender;
        Voter storage delegateFromVoter = voters[msg.sender];
        Voter storage delegateToVoter = voters[delegateToAddress];

        require(
            !delegateFromVoter.voted,
            "The voter already voted"
        );
        require(
            delegateFromAddress != delegateToAddress,
            "Self delegation is not allowed."
        );
        require(
            delegateToVoter.delegate != address(0),
            "Found potentially endless loop in delegation"
        );

        delegateFromVoter.voted = true;
        delegateToVoter.voted = false;
        delegateToVoter.weight += delegateFromVoter.weight;
    }

    function vote(uint proposalId) public {
        Voter storage voter = voters[msg.sender];
        require(!voter.voted);
        require(proposalId >= 0 && proposalId < proposals.length);

        proposals[proposalId].votes += voter.weight;
        voter.voted = true;
        voter.vote.push(proposalId);
        voter.weight = 0;
    }

    function winningProposal() public view returns (uint winningProposal_) {
        uint biggestVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (p > biggestVoteCount) {
                biggestVoteCount = proposals[p].votes;
                winningProposal_ = p;
            }
        }
    }
}
