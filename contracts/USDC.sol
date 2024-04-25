// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20FixedSupply is ERC20 {
    
    constructor() public ERC20("USDC", "USDC") {
        _mint(msg.sender, 1000);
    }
}
