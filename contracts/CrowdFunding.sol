// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract CrowdFunding {
    // Defining Contributors:
    mapping(address => uint256) public contributors;
    // contributors address => ether they contributed

    // Defining Manager:
    address public manager;

    // minimum contribution of eth
    uint256 public minimumContribution;

    // deadline
    uint256 public deadline;

    // target
    uint256 public target;

    // raised amount
    uint256 public raisedAmount;

    // No. of Contributors
    uint256 public noOfContributors;

    // structure for Request, where manager will request to extract ether from contract
    struct Request {
        // why you are requesting
        string description;
        // whom you want to give eth
        address payable recipient;
        // how much you want to give
        uint256 value;
        // is request completed
        bool completed;
        // how much contributor voted
        uint256 noOfVoters;
        // did contributors approved or not
        mapping(address => bool) voters;
    }
    // to store all the request from this contract
    mapping(uint256 => Request) public requests;
    //  number of request on this contract
    uint256 public numRequests;

    constructor(uint256 _target, uint256 _deadline) {
        // while deploying this smart contract manager will set 'target' and 'deadline' and some other required field
        target = _target;
        deadline = block.timestamp + _deadline;
        // timestamp : in unix terms
        // if we have deadline of 1 hour then:
        // _deadline = 1 * 60 * 60
        // <deployed_time> + _deadline
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable {
        // this function will help to send eth by contributors

        // contributors need to send ether under the deadline date
        require(block.timestamp < deadline, "Deadline had passed");

        // Minimum eth condition
        require(
            msg.value >= minimumContribution,
            "Minimum Contribution is not met"
        );

        if (contributors[msg.sender] == 0) {
            // If contributor has not contributed on this contract yet and just contributed now

            noOfContributors++;
        }
        // contributor can contribute multiple times
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getContractBalance() public view returns (uint256) {
        // return contract balance
        return address(this).balance;
    }

    function refund() public {
        // if target did not get met on deadline then contributor will get refund

        // target should not get reached and deadline is cross condition:
        require(
            block.timestamp > deadline && raisedAmount < target,
            "target is fulfilled so can't get refund"
        );

        // if someone try to get refund but have on contributed condition
        require(
            contributors[msg.sender] > 0,
            "You have not contributed. so, can't get refund"
        );

        // now if condition get match then we will refund contributor
        address payable user = payable(msg.sender);
        // so firstly we have to make msg.sender payable

        // now send the same amount that contributor contributed
        user.transfer(contributors[msg.sender]);

        // now contributor value will become 0
        // contributors[msg.sender] = 0;
        // now we will delete contributor
        delete contributors[msg.sender];
    }

    // now we will create request which is only be able to access by manager
    // because only manager can request it means that first we have to make modifier
    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can request");
        _;
    }

    function createRequest(
        string memory _description,
        address _recipient,
        uint256 _value
    ) public onlyManager {
        // now we will take required argument to create request
        // and we will add 'onlyManager' modifier because only a manger can call this function

        // now we will create new Request 'newRequest'
        // because we are using mapping inside struct we have to use storage
        Request storage newRequest = requests[numRequests];
        numRequests++;

        // now we will assign the value to new Request
        newRequest.description = _description;
        newRequest.recipient = payable(_recipient);
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    // now we will vote the request through contributors
    function voteRequest(uint256 _requestNo) public {
        // _requestNo: which request you want to vote

        // does voting person is contributor of this contract or not:
        require(
            contributors[msg.sender] > 0,
            "You must be a contributor to vote"
        );

        // create instance of Request
        Request storage thisRequest = requests[_requestNo];

        // does contributor already voted or not
        require(
            thisRequest.voters[msg.sender] == false,
            "You have already voted"
        );

        // is request is already completed
        require(thisRequest.completed == false, "Request is completed");

        // now we will add new voter to the request
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    // now we will pay to the recipient for which request had been opened
    function makePayment(uint256 _requestNo) public onlyManager {
        // only manager can pay to recipient

        // does raised amount is greater then target
        require(raisedAmount >= target);

        // create instance Request
        Request storage thisRequest = requests[_requestNo];

        // does we already pay to that Request
        require(
            thisRequest.completed == false,
            "The request has been completed"
        );

        // noOfVoters > 50% of noOfContributors
        require(
            thisRequest.noOfVoters > noOfContributors / 2,
            "Majority does not support"
        );

        // now we will transfer the request amount to recipient
        thisRequest.recipient.transfer(thisRequest.value);

        // now this request is complete
        thisRequest.completed = true;
    }
}
