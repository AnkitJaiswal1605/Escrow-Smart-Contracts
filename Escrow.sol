// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./StableCoin.sol";
import "./Token.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Escrow is ERC1155Holder {
    StableCoin public stableCoin;
    Token public token;
    mapping(uint => uint) public itemPrice;
    mapping(uint => address) public seller;
    mapping(uint => uint) public buyDeadline;

    constructor(StableCoin _stableCoin, Token _token) {
        stableCoin = _stableCoin;
        token = _token;
    }

    function listToken(uint _id, uint _itemPrice, uint listPeriodInHrs) public {
        token.safeTransferFrom(msg.sender, address(this), _id, 1, "");
        itemPrice[_id] = _itemPrice;
        seller[_id] = msg.sender;
        buyDeadline[_id] = block.timestamp + listPeriodInHrs*60*60;
    }

    function buyToken(uint _id) public {
        require(block.timestamp <= buyDeadline[_id], "Deadline Passed!");
        stableCoin.transferFrom(msg.sender, seller[_id], itemPrice[_id]);
        token.safeTransferFrom(address(this), msg.sender, _id, 1, "");
    }
}
