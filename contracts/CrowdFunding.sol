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
}
