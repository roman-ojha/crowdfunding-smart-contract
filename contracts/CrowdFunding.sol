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
    mapping(uint256 => Request) public request;
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

    //
}
