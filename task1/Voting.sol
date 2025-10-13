// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// 一个mapping来存储候选人的得票数
// 一个vote函数，允许用户投票给某个候选人
// 一个getVotes函数，返回某个候选人的得票数
// 一个resetVotes函数，重置所有候选人的得票数
contract Voting {
    mapping(string => uint256) votes;

    string[] public candidates;

    mapping(address => uint256) hasVoted;
    
    // mapping(address => string) hasVoted;

    uint256 public currentRound = 1;

    event Voted(address indexed voter, string candidate);

    event ResetVotesEvent(address indexed resetBy);

    function vote(string memory _candidate) public {
        require(hasVoted[msg.sender] != currentRound, "you have already voted");

        votes[_candidate] += 1;
        hasVoted[msg.sender] = currentRound;
        candidates.push(_candidate);
        emit Voted(msg.sender, _candidate);
    }

    function getVotes(string memory _candidate) public view returns(uint256) {
        require(bytes(_candidate).length > 0, "Candidate name cannot be empty");
        return votes[_candidate];
    }

    function resetVotes() public {
        for (uint i = 0; i < candidates.length; i++){
            delete votes[candidates[i]];
        }
        delete  candidates;
        currentRound++;
        emit ResetVotesEvent(msg.sender);
    }

    function cc() public view returns(string[] memory c) {
        return candidates;
    }

}