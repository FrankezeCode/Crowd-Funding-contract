// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;


contract CrowdFunding {

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint  noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint=>Request) public requests;

    mapping(address => uint ) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    uint public numRequest;


    constructor(uint _target, uint _deadline){
       target = _target;
       deadline = block.timestamp + _deadline;
       manager = msg.sender;
       minimumContribution = 1 ether;
    }

    modifier onlyManager(){
        require(msg.sender == manager, "You are not the manager");
        _;
    }


    function createRequest(string memory _description , address payable _recipient, uint _value)  public onlyManager {
        Request storage newRequest = requests[numRequest];
        newRequest.description = _description;
        newRequest.value = _value;
        newRequest.recipient = _recipient;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        numRequest++;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution, "Not enough Ether");
        require( block.timestamp < deadline, "No more contribution");

        if(contributors[msg.sender] == 0){ /*This is to ensure that ,only new contributors can be added, 
                                            while only value of existing contributors is increased */
            noOfContributors++;
        }
        
        contributors[msg.sender] += msg.value;// this increases the value contributed, from an existing contributor
        raisedAmount += msg.value;
            
    }

    function balance() public view  returns (uint){
        return address(this).balance;
    }

    function refund() public {
        require(block.timestamp > deadline || raisedAmount < target , " Cant be refunded" );
        require(contributors[msg.sender] > 0, "You are not a contributor" );

        payable(msg.sender).transfer(contributors[msg.sender]);
    }


    function voteRequest(uint requestNo) public {
        require(contributors[msg.sender] > 0, "You are not a contributor" );
        require(requests[requestNo].completed == false, "Request has been completed");
        require(requests[requestNo].voters[msg.sender]  == false, "voted Already");

        requests[requestNo].voters[msg.sender] = true;
        requests[requestNo].noOfVoters++;
      
        
    }
        
    function makePayment(uint requestNo) public payable onlyManager{
      Request storage thisRequest = requests[requestNo];
      require(thisRequest.completed == false, "Request has been completed");
      require(thisRequest.noOfVoters > noOfContributors/2, "Request not approve" );
      require(raisedAmount >= target, "unable to raise Fund");

      thisRequest.recipient.transfer(thisRequest.value);
      thisRequest.completed = true;
    }
    
   
  
}