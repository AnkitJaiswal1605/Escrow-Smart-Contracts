// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Coin.sol";
import "./Token.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

// This contract will be used to list seller products as ERC 1155 tokens
// Buyers will be able to pay for the tokens with the ERC 20 coins

contract Escrow is ERC1155Holder {
    Coin public coin;
    Token public token;

    // To map the price against the item
    mapping(uint => uint) public itemPrice;
    
    // To map the seller against the item's id number
    mapping(uint => address) public seller;

    // To map the deadline for buying the item against the item's id number
    mapping(uint => uint) public buyDeadline;

    // Defining the coin and token contracts in the constructor
    constructor(Coin _coin, Token _token) {
        coin = _coin;
        token = _token;
    }

    // Token will be transferred to the contract and itemprice, seller and buyDeadline mappings will be set
    function listToken(uint _id, uint _itemPrice, uint listPeriodInHrs) public {
        token.safeTransferFrom(msg.sender, address(this), _id, 1, "");
        itemPrice[_id] = _itemPrice;
        seller[_id] = msg.sender;
        buyDeadline[_id] = block.timestamp + listPeriodInHrs*60*60;
    }

    // Deadline will be checked and ERC 20 coins will be first transferred to the seller
    // After these two steps, the token will be transferred to the buyer
    function buyToken(uint _id) public {
        require(block.timestamp <= buyDeadline[_id], "Deadline Passed!");
        coin.transferFrom(msg.sender, seller[_id], itemPrice[_id]);
        token.safeTransferFrom(address(this), msg.sender, _id, 1, "");
    }
}

/* Alternatives:
** In buy token function, instead of transferring the coins and token to seller and buyer respectively,
   we could have used a mapping to store the tokens and coins for the buyer and seller to claim whenever they want.
   Just that, it would have cost more gas.

** We could also give names and symbols to each token, so that users could identify tokens easily instead of using ID numbers.
*/

/* Security considerations:

** Re-entrancy:
   In the buyToken function, it's important that coins are transferred to seller first before transferring token to buyer.
   Otherwise, a hacker can use a fallback function in a smart contract to take advantage of it.
   Alternatively, we could lock the function till it's complete.

** Overflow and underflow:
   It's automatically taken care of in solidity versions >8.0,
   otherwise SafeMath library should be used.

** Certain functions in the ERC 20 and ERC 1155 contracts can be accessed by only owner by using the Ownable contract.

*/
