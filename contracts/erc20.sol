// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LifeToken is ERC20 {

    uint public supply = 40000000;

    constructor() public ERC20("Life", "LT") {}

    function mint(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        _mint(msg.sender, _amount);
    }
}