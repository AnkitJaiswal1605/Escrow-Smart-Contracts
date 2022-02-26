// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// This coin is pegged to ETH. Initially, it's pegged at 0.01 ETH per coin
// It will be used to buy ERC 1155 token listed by the seller on the Escrow contract

contract Coin is ERC20, ERC20Burnable, Pausable, Ownable {
    
    uint public price = 0.01 ether;
    
    constructor() ERC20("Coin", "COIN") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(uint256 amount) public payable {
        require(msg.value == price);
        _mint(msg.sender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
