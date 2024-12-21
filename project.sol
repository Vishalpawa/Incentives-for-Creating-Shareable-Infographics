// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IncentiveInfographics {
    address public owner;
    uint public infographicCounter;
    uint public rewardAmount;

    struct Infographic {
        uint id;
        address creator;
        string ipfsHash;
        uint timestamp;
        uint totalShares;
    }

    mapping(uint => Infographic) public infographics;
    mapping(uint => mapping(address => bool)) public shared;
    mapping(address => uint) public earnedRewards;

    event InfographicCreated(uint id, address creator, string ipfsHash, uint timestamp);
    event InfographicShared(uint id, address sharer);
    event RewardsWithdrawn(address recipient, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier validInfographic(uint id) {
        require(infographics[id].creator != address(0), "Infographic does not exist");
        _;
    }

    constructor(uint initialRewardAmount) {
        owner = msg.sender;
        rewardAmount = initialRewardAmount;
    }

    function createInfographic(string memory ipfsHash) external {
        infographicCounter++;
        infographics[infographicCounter] = Infographic(
            infographicCounter,
            msg.sender,
            ipfsHash,
            block.timestamp,
            0
        );
        emit InfographicCreated(infographicCounter, msg.sender, ipfsHash, block.timestamp);
    }

    function shareInfographic(uint id) external validInfographic(id) {
        require(!shared[id][msg.sender], "Already shared by this user");
        
        shared[id][msg.sender] = true;
        infographics[id].totalShares++;
        
        earnedRewards[msg.sender] += rewardAmount;
        emit InfographicShared(id, msg.sender);
    }

    function withdrawRewards() external {
        uint rewards = earnedRewards[msg.sender];
        require(rewards > 0, "No rewards to withdraw");

        earnedRewards[msg.sender] = 0;
        payable(msg.sender).transfer(rewards);
        emit RewardsWithdrawn(msg.sender, rewards);
    }

    function updateRewardAmount(uint newAmount) external onlyOwner {
        rewardAmount = newAmount;
    }

    function depositFunds() external payable onlyOwner {}

    function getInfographic(uint id) external view validInfographic(id) returns (Infographic memory) {
        return infographics[id];
    }

    function getEarnedRewards(address user) external view returns (uint) {
        return earnedRewards[user];
    }

    receive() external payable {}
}
