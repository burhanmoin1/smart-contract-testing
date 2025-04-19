// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract FurreverCoin is ERC20, Ownable {
    
    using SafeMath for uint256;

    uint256 public constant TOTAL_SUPPLY = 111 * 10**12 * 10**18;  // 111 Trillion tokens with 18 decimals
    address _teamPlayer2;
    address _teamPlayer3;
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    uint256 public currentPhase = 1;
    uint256 public presalePrice = 0.0000005 * 10**18; // Initial price in wei (ETH/BNB equivalent)
    
    uint256 public presaleTokensSold = 0;
    uint256 public presaleTokenCap = 27.5 * 10**12 * 10**18; // 24.77% of the total supply for presale
    uint256 public liquidityPoolTokens = 22.2 * 10**12 * 10**18; // 20% of total tokens for liquidity
    uint256 public animalWelfareFundTokens = 11.1 * 10**12 * 10**18; // 10% for charity

    // Define token allocation
    mapping(address => uint256) public presalePurchasers;
    
    // Vesting mechanism for team tokens
    mapping(address => uint256) public teamTokenVesting;
    
    event TokensPurchased(address indexed purchaser, uint256 amount);
    event TokensBurned(uint256 amount);
    
    constructor() ERC20("FurreverCoin", "FURR") Ownable(msg.sender) {
        // Mint initial tokens
        _mint(address(this), TOTAL_SUPPLY);
    }

    // Presale function to allow buying tokens in presale
    function buyTokens(uint256 amount) external payable {
        require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Presale is not active.");
        
        uint256 cost = amount.mul(presalePrice);
        require(msg.value >= cost, "Insufficient funds.");
        
        // Track the amount purchased by each address
        presalePurchasers[msg.sender] = presalePurchasers[msg.sender].add(amount);
        
        // Transfer purchased tokens
        _transfer(address(this), msg.sender, amount);
        
        // Emit event
        emit TokensPurchased(msg.sender, amount);
    }

    // Function to start the presale
    function startPresale(uint256 startTime, uint256 endTime) external onlyOwner {
        presaleStartTime = startTime;
        presaleEndTime = endTime;
    }

    // Function to increment the presale price after each phase
    function incrementPresalePrice() external onlyOwner {
        require(block.timestamp > presaleEndTime, "Presale is still active");
        
        if (currentPhase == 1 || currentPhase == 9) {
            presalePrice = presalePrice.mul(120).div(100);  // 20% price increase for the first and last stage
        } else {
            presalePrice = presalePrice.mul(110).div(100);  // 10% price increase for other stages
        }
        
        currentPhase++;
    }

    // Burn unsold tokens after the presale
    function burnUnsoldTokens() external onlyOwner {
        uint256 unsoldTokens = presaleTokenCap.sub(presaleTokensSold);
        _burn(address(this), unsoldTokens);
        emit TokensBurned(unsoldTokens);
    }

    // Function to handle liquidity pool tokens after presale
    function transferLiquidityPool() external onlyOwner {
        _transfer(address(this), owner(), liquidityPoolTokens);
    }

    // Team tokens vesting schedule
    function releaseVestedTokens(address teamMember) external onlyOwner {
        uint256 releaseAmount = teamTokenVesting[teamMember];
        require(releaseAmount > 0, "No tokens to release.");
        
        teamTokenVesting[teamMember] = 0;
        _transfer(address(this), teamMember, releaseAmount);
    }

    // Function to lock team tokens and allocate vesting
    function lockTeamTokens(address teamMember, uint256 amount) external onlyOwner {
        teamTokenVesting[teamMember] = amount;
    }

    // Function to withdraw collected funds (ETH/BNB) from presale
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Anti-bot protection: basic implementation could limit buys per address per block
    modifier antiBotProtection() {
        require(presalePurchasers[msg.sender] == 0, "Address already purchased tokens.");
        _;
    }

    // Fallback function to receive BNB/ETH
    receive() external payable {}
}
