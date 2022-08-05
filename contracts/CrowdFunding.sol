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
}
