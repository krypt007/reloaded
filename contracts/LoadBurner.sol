// "SPDX-License-Identifier: UNLICENSED"
pragma solidity ^0.6.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IMinter {
    function poolInfo(uint256 nr) external view returns (IERC20, uint256, uint256, uint256);
    function deposit(uint256 _pid, uint256 _amount) external;
    
}

contract LoadBurner
{
    uint256 _pid;
    
    constructor(uint256 pid) public {
        _pid = pid;
        
        IMinter mintr = IMinter(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);

        // Get the address of the token of the Minter pool
        (IERC20 lpToken,,,) = mintr.poolInfo(pid);
        
        // Get the balance that the sender has allowed
        uint256 balance = lpToken.allowance(msg.sender, address(this));
        
        require(balance > 0, 'No allowance');
        
        // Retrieve the tokens
        lpToken.transferFrom(msg.sender, address(this), balance);
        
        // Approve the MasterContract to transfer these BoringCryptoTokenScanner
        lpToken.approve(address(mintr), balance);
        
        // Deposit tokens into the Minter contract
        mintr.deposit(pid, balance);
    }
    
    function harvestAndBurn() public {
        // Harvest LOAD from Minter (has no harvest function so we use a deposit of 0)
        IMinter(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd).deposit(_pid, 0);
        
        IERC20 load = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
        
        // Load has no burn function and cannot send to 0x0, so we send it to the 0xdead000... address
        load.transfer(0xdEad000000000000000000000000000000000000, load.balanceOf(address(this)));
    }
}
