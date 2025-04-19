// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AnimalToken is ERC20, Ownable {
    // Define events
    event TokensTransferred(address indexed from, address indexed to, uint256 amount);
    event MintExecuted(address indexed to, uint256 amount);

    address public teamPlayer2;
    address public teamPlayer3;
    address public ownerAddress;
    address public liquidityWallet;
    address public animalFundWallet;
    address public communityRewardsWallet;
    address public devMarketingWallet;

    uint256 public constant TOTAL_SUPPLY = 111_000_000_000_000 * 1e18;

    constructor(
        address _teamPlayer2,
        address _teamPlayer3,
        address _liquidityWallet,
        address _animalFundWallet,
        address _communityRewardsWallet,
        address _devMarketingWallet
    ) ERC20("AnimalToken", "ATK") Ownable(msg.sender) {
        // Set addresses for allocation
        teamPlayer2 = _teamPlayer2;
        teamPlayer3 = _teamPlayer3;
        ownerAddress = msg.sender;
        liquidityWallet = _liquidityWallet;
        animalFundWallet = _animalFundWallet;
        communityRewardsWallet = _communityRewardsWallet;
        devMarketingWallet = _devMarketingWallet;

        // Mint full supply to contract itself for controlled distribution
        _mint(address(this), TOTAL_SUPPLY);

        // Distribute allocations and emit events for these transfers
        transferAndEmitEvent(_teamPlayer2, 3_000_000_000_000 * 1e18);
        transferAndEmitEvent(_teamPlayer3, 3_000_000_000_000 * 1e18);
        transferAndEmitEvent(ownerAddress, 22_000_000_000_000 * 1e18);
    }

    // Function that handles both token transfer and event emission
    function transferAndEmitEvent(address to, uint256 amount) internal {
        _transfer(address(this), to, amount); // Transfer the tokens
        emit TokensTransferred(address(this), to, amount); // Emit the event
    }

    // Example of a mint function that emits an event when tokens are minted
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        emit MintExecuted(to, amount);  // Emit event on mint
    }
}
