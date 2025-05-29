// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    address public admin;
    string public electionName;
    bool public votingActive;
    uint256 public totalCandidates;
    uint256 public totalVotes;
    
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event ElectionEnded(uint256 totalVotes);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "Voter not registered");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        _;
    }
    
    constructor(string memory _electionName) {
        admin = msg.sender;
        electionName = _electionName;
        votingActive = true;
        totalCandidates = 0;
        totalVotes = 0;
    }
    
    // Core Function 1: Register voters and add candidates
    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    function addCandidate(string memory _name) public onlyAdmin {
        totalCandidates++;
        candidates[totalCandidates] = Candidate({
            id: totalCandidates,
            name: _name,
            voteCount: 0
        });
    }
    
    // Core Function 2: Cast vote
    function vote(uint256 _candidateId) public onlyRegisteredVoter votingIsActive {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    // Core Function 3: Get results and end election
    function getResults() public view returns (Candidate[] memory) {
        Candidate[] memory allCandidates = new Candidate[](totalCandidates);
        
        for (uint256 i = 1; i <= totalCandidates; i++) {
            allCandidates[i - 1] = candidates[i];
        }
        
        return allCandidates;
    }
    
    function endElection() public onlyAdmin {
        require(votingActive, "Election already ended");
        votingActive = false;
        emit ElectionEnded(totalVotes);
    }
    
    // Additional utility functions
    function getWinner() public view returns (string memory winnerName, uint256 winnerVotes) {
        require(!votingActive, "Election is still active");
        require(totalCandidates > 0, "No candidates available");
        
        uint256 maxVotes = 0;
        uint256 winnerId = 0;
        
        for (uint256 i = 1; i <= totalCandidates; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }
        
        return (candidates[winnerId].name, maxVotes);
    }
    
    function hasVoterVoted(address _voter) public view returns (bool) {
        return voters[_voter].hasVoted;
    }
    
    function getCandidateVotes(uint256 _candidateId) public view returns (uint256) {
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }
}
