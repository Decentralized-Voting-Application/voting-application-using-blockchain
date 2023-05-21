// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Vote {
    address public electionCommision;

    address public winner;

    struct Voter {
        string name;
        uint256 age;
        uint256 voterId;
        string gender;
        uint256 voteCandidateId;
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party;
        uint256 age;
        string gender;
        uint256 candidateId;
        address candidateAddress;
        uint256 votes;
    }

    uint256 nextVoterId = 1;

    uint256 nextCandidateId = 1;

    uint256 startTime;

    uint256 endTime;

    mapping(uint256 => Voter) voterDetails;

    mapping(uint256 => Candidate) candidateDetails;

    bool stopVoting; 

    constructor() {
        electionCommision = msg.sender; 
    }

    
    function candidateRegister(
        string calldata _name,
        string calldata _party,
        uint256 _age,
        string calldata _gender
    ) external {
        require(
            msg.sender != electionCommision,
            "You are from election commision"
        );

        require(
            candidateVerification(msg.sender),
            "You have already registered"
        );

        require(_age >= 18, "You re below 18");

        require(nextCandidateId < 3, "Registration full");

        candidateDetails[nextCandidateId] = Candidate(
            _name,
            _party,
            _age,
            _gender,
            nextCandidateId,
            msg.sender,
            0
        );

        nextCandidateId++;
    }

    function candidateVerification(address _person)
        internal
        view
        returns (bool)
    {
        for (uint256 i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].candidateAddress == _person) {
                return false;
            }
        }

        return true;
    }

    function candidateList() public view returns (Candidate[] memory) {
        Candidate[] memory arr = new Candidate[](nextCandidateId - 1); //empty array,length=nextCandidateId-1

        for (uint256 i = 1; i < nextCandidateId; i++) {
            arr[i - 1] = candidateDetails[i];
        }

        return arr;  
    }

    function voterRegister(
        string calldata _name,
        uint256 _age,
        string calldata _gender
    ) external {
        require(voterVerification(msg.sender), "You have already registrated");

        require(_age >= 18, "You are not eligbile to vote");

        voterDetails[nextVoterId] = Voter(
            _name,
            _age,
            nextVoterId,
            _gender,
            0,
            msg.sender
        );

        nextVoterId++;
    }

    function voterVerification(address _user) internal view returns (bool) {
        for (uint256 i = 1; i < nextVoterId; i++) {
            if (voterDetails[i].voterAddress == _user) {
                return false;
            }
        }

        return true;
    }

    function voterList() public view returns (Voter[] memory) {
        Voter[] memory arr = new Voter[](nextVoterId - 1);

        for (uint256 i = 1; i < nextVoterId; i++) {
            arr[i - 1] = voterDetails[i];
        }

        return arr;
    }

    function vote(uint256 _voterId, uint256 _id) external isVotingOver {
        require(
            voterDetails[_voterId].voteCandidateId == 0,
            "You have already voted"
        );

        require(
            voterDetails[_voterId].voterAddress == msg.sender,
            "You are not registered"
        );

        require(block.timestamp > startTime, "Voting has not started");

        require(nextCandidateId > 2, "Canidate registration is not done yet");

        require(_id > 0 && _id < 3, "Candidate does not exist");

        voterDetails[_voterId].voteCandidateId = _id;

        candidateDetails[_id].votes++;
    }

    function voteTime(uint256 _startTime, uint256 _endTime) external {
        require(
            electionCommision == msg.sender,
            "You are not from election commision"
        );

        startTime = block.timestamp + _startTime; //5pm+5 minutes = 5:05 minutes

        endTime = startTime + _endTime; //5:05+20 minute= 5:25 minutes

        stopVoting = false;
    }



    function votingStatus() external view returns (string memory) {
        if (startTime == 0) {
            return "Voting Not Started";
        } else if (
            (startTime != 0 && endTime > block.timestamp) && stopVoting == false
        ) {
            return "Voting in progress";
        } else {
            return "Voting Ended";
        }
    }

    function result() external {
        require(
            electionCommision == msg.sender,
            "You are not from election commision"
        );

        Candidate[] memory arr = new Candidate[](nextCandidateId - 1);

        arr = candidateList();

        if (arr[0].votes > arr[1].votes) {
            winner = arr[0].candidateAddress;
        } else {
            winner = arr[1].candidateAddress;
        }
    }

    function emergency() public {
        require(
            electionCommision == msg.sender,
            "You are not from election commision"
        );

        stopVoting = true;
    }

    modifier isVotingOver() {
        require(endTime > block.timestamp || stopVoting, "Voting is over");

        _;
    }
}