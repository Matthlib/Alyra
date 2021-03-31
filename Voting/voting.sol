// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.7 .0 < 0.9 .0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */


contract Voting is Ownable {

    // variable who manage the vote
    WorkflowStatus VotingSession = WorkflowStatus.RegisteringVoters;

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        address votedProposalId;
        WorkflowStatus status;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }


    //Vote action
    //--------------------------------
    event VotingSessionStarted();
    event VotingSessionEnded();
    event VoterRegistered(address voterAddress);
    event Voted(address voter, uint proposalId);
    event VotesTallied();
    event ProposalsRegistrationStarted();
    event ProposalsRegistrationEnded();
    event ProposalRegistered(uint proposalId);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    address winningProposaladdress;
    mapping(address => Voter) public _whitelist;
    mapping(address => Proposal) public _proposallist;
    address[] public _whitelistAdress;
    address[] public _proposalAdress;

    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    //0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    //0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    //0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB


    //---------------------------------
    // Voter part
    //---------------------------------
    function addVoter(address _address) public onlyOwner {
        require(VotingSession == WorkflowStatus.RegisteringVoters, "you are not in the correct step to add new voter");
        bool check = false;
        for (uint o = 0; o < _whitelistAdress.length; o++) {
            if (_whitelistAdress[o] == _address) {
                check = true;
            }
        }
        require(!check, "voter already in the list");
        _whitelistAdress.push(_address);
        Voter memory newvoter = Voter(true, false, 0x0000000000000000000000000000000000000000, WorkflowStatus.RegisteringVoters);
        _whitelist[_address] = newvoter;
    }

    function viewAllVoters() public view returns(address[] memory) {
        return _whitelistAdress;
    }


    function viewVoter(address _address) public view returns(bool, bool, address, WorkflowStatus) {
        return (_whitelist[_address].isRegistered, _whitelist[_address].hasVoted, _whitelist[_address].votedProposalId, _whitelist[_address].status);
    }

    //---------------------------------
    // changement of status of the vote
    //---------------------------------
    function changeWorkflowStatus(WorkflowStatus _status) public onlyOwner returns(bool) {
        if (_status == WorkflowStatus.ProposalsRegistrationStarted) {emit ProposalsRegistrationStarted(); }
        if (_status == WorkflowStatus.ProposalsRegistrationEnded) {emit ProposalsRegistrationStarted();}
        if (_status == WorkflowStatus.VotingSessionStarted) {emit VotingSessionStarted();}
        if (_status == WorkflowStatus.VotingSessionEnded) {emit VotingSessionEnded();}
        //add the changement of status
        if (_whitelist[_whitelistAdress[1]].isRegistered = true) {emit WorkflowStatusChange(_whitelist[_whitelistAdress[1]].status, _status);
        } else {emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, _status);
        }
        //change on the voter the event
        for (uint o = 0; o < _whitelistAdress.length; o++) {
            _whitelist[_whitelistAdress[o]].status = _status;
        }
        VotingSession = _status;
        return true;
    }

    function viewCurrentWorkflowStatus() public view returns(string memory) {
        if (WorkflowStatus.RegisteringVoters == VotingSession) return "RegisteringVoters";
        if (WorkflowStatus.ProposalsRegistrationStarted == VotingSession) return "ProposalsRegistrationStarted";
        if (WorkflowStatus.ProposalsRegistrationEnded == VotingSession) return "ProposalsRegistrationEnded";
        if (WorkflowStatus.VotingSessionStarted == VotingSession) return "VotingSessionStarted";
        if (WorkflowStatus.VotingSessionEnded == VotingSession) return "VotingSessionEnded";
        if (WorkflowStatus.VotesTallied == VotingSession) return "VotesTallied";

    }


    //---------------------------------
    // Proposale part
    //---------------------------------
    function addproposal(address _address) public returns(bool) {
        bool check = false;
        require(VotingSession == WorkflowStatus.ProposalsRegistrationStarted, "you are not in the correct step to add  of the vote");
        require(_whitelist[msg.sender].isRegistered == true, "your adress is not registered, please ask the admin");
        require(_whitelist[_address].isRegistered == true, "Your proposal need to be part of the voters. please ask the admin");
        require(_whitelist[msg.sender].status == WorkflowStatus.ProposalsRegistrationStarted, "you are not in the right session of registration!");
        for (uint o = 0; o < _proposalAdress.length; o++) {
            if (_proposalAdress[o] == _address) {
                check = true;
            }
        }
        require(check == false, "Proposal already in the list");
        _proposalAdress.push(_address);
        _proposalAdress.push(_address);
        _proposallist[_address].description = "";
        _proposallist[_address].voteCount = 0;
        return true;
    }

    function viewproposal(address _address) public view returns(string memory, uint) {
        return (_proposallist[_address].description, _proposallist[_address].voteCount);
    }

    function viewAllProposal() public view returns(address[] memory) {
        return _proposalAdress;
    }

    //---------------------------------
    // vote part
    //---------------------------------
    function addvote(address _address) public returns(uint) {
        bool check = false;
        require(VotingSession == WorkflowStatus.VotingSessionStarted, "you are not in the correct step to add  of the vote");
        require(_whitelist[msg.sender].status == WorkflowStatus.VotingSessionStarted, "the session of vote havent started yet!");
        require(!_whitelist[msg.sender].hasVoted, "you are already voted");
        require(_whitelist[_address].isRegistered, "Your proposal need to be part of the voters. please ask the admin");
        for (uint o = 0; o < _proposalAdress.length; o++) {
            if (_proposalAdress[o] == _address) {
                check = true;
            }
        }
        require(check, "Voter is not in proposal list");
        uint count = _proposallist[_address].voteCount;
        count = count + 1;
        _proposallist[_address].voteCount = count;
        _whitelist[msg.sender].hasVoted = true;
        _whitelist[msg.sender].votedProposalId = _address;
        return count;

    }

    //---------------------------------
    // vote part
    //---------------------------------
    function TopVictoryAdress() public view returns(address) {
        require(VotingSession == WorkflowStatus.VotesTallied, "you are not in the correct step to view the results of the vote");
        uint largest = 0;
        uint largestID = 0;
        /** get the index of the current max element **/
        for (uint i = 0; i < _proposalAdress.length; i++) {
            if (_proposallist[_proposalAdress[i]].voteCount > largest) {
                largest = _proposallist[_proposalAdress[i]].voteCount;
                largestID = i;
            }
        }
        address returnAdress = _proposalAdress[largestID];
        return returnAdress;
    }


}