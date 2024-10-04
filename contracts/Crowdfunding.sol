// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    struct Campaign {
        address creator;
        string title;
        uint256 targetAmount;
        uint256 raisedAmount;
        uint256 deadline;
        bool isComplete;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    uint256 public campaignCount;

    event CampaignCreated(uint256 id, address creator, string title, uint256 targetAmount, uint256 deadline);
    event Funded(uint256 campaignId, address contributor, uint256 amount);
    event Withdrawn(uint256 campaignId, uint256 amount);

    modifier onlyCreator(uint256 campaignId) {
        require(msg.sender == campaigns[campaignId].creator, "Not the campaign creator");
        _;
    }

    modifier notComplete(uint256 campaignId) {
        require(!campaigns[campaignId].isComplete, "Campaign already completed");
        _;
    }

    modifier campaignActive(uint256 campaignId) {
        require(block.timestamp < campaigns[campaignId].deadline, "Campaign has ended");
        _;
    }

    // Create a new crowdfunding campaign
    function createCampaign(string memory title, uint256 targetAmount, uint256 duration) public {
        require(duration > 0, "Duration must be greater than 0");
        
        campaignCount++;
        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            title: title,
            targetAmount: targetAmount,
            raisedAmount: 0,
            deadline: block.timestamp + duration,
            isComplete: false
        });

        emit CampaignCreated(campaignCount, msg.sender, title, targetAmount, campaigns[campaignCount].deadline);
    }

    // Contribute to a campaign
    function fundCampaign(uint256 campaignId) public payable notComplete(campaignId) campaignActive(campaignId) {
        require(msg.value > 0, "Contribution must be greater than 0");
        
        contributions[campaignId][msg.sender] += msg.value;
        campaigns[campaignId].raisedAmount += msg.value;

        emit Funded(campaignId, msg.sender, msg.value);
    }

    // Withdraw funds if the campaign is successful
    function withdrawFunds(uint256 campaignId) public onlyCreator(campaignId) {
        require(block.timestamp >= campaigns[campaignId].deadline, "Campaign is still active");
        require(campaigns[campaignId].raisedAmount >= campaigns[campaignId].targetAmount, "Target not reached");
        
        uint256 amount = campaigns[campaignId].raisedAmount;
        campaigns[campaignId].isComplete = true;
        payable(msg.sender).transfer(amount);
        
        emit Withdrawn(campaignId, amount);
    }

    // Check if the campaign is successful
    function isSuccessful(uint256 campaignId) public view returns (bool) {
        return campaigns[campaignId].raisedAmount >= campaigns[campaignId].targetAmount;
    }
}
