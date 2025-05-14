// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RedemptionToken
 * @dev Standard ERC20 token that will be given in exchange for voucher tokens
 */
contract RedemptionToken is ERC20, Ownable {
    /**
     * @dev Constructor
     * @param name Token name
     * @param symbol Token symbol
     * @param initialOwner Initial owner address
     */
    constructor(
        string memory name,
        string memory symbol,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {}

    /**
     * @dev Mint tokens to an account (only owner)
     * @param to Recipient of the tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Burn tokens from an account (only owner)
     * @param from Account to burn from
     * @param amount Amount of tokens to burn
     */
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
