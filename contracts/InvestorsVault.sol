// "SPDX-License-Identifier: UNLICENSED"
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// InvestorsVault is the coolest vault in town. You come in with some Load, and leave with more! The longer you stay, the more Load you get.
//
// This contract handles swapping to and from reLoad, Reloaded's staking token.
contract InvestorsVault is ERC20("InvestorsVault", "reLOAD"){
    using SafeMath for uint256;
    IERC20 public load;

    // Define the Load token contract
    constructor(IERC20 _load) public {
        load = _load;
    }

    // Enter the vault. Pay some LOADs. Earn some shares.
    // Locks Load and mints reLoad
    function enter(uint256 _amount) public {
        // Gets the amount of Load locked in the contract
        uint256 totalLoad = load.balanceOf(address(this));
        // Gets the amount of reLoad in existence
        uint256 totalShares = totalSupply();
        // If no reLoad exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalLoad == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of reLoad the Load is worth. The ratio will change overtime, as reLoad is burned/minted and Load deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalLoad);
            _mint(msg.sender, what);
        }
        // Lock the Load in the contract
        load.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the vault. Claim back your LOADs.
    // Unclocks the staked + gained Load and burns reLoad
    function leave(uint256 _share) public {
        // Gets the amount of reLoad in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Load the reLoad is worth
        uint256 what = _share.mul(load.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        load.transfer(msg.sender, what);
    }
}