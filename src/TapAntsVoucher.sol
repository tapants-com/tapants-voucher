// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TapAntsVoucher
 * @dev A non-transferable voucher token for Tap Ants that can only be spent via approved redemption
 */
contract TapAntsVoucher is ERC20, Ownable {
    uint256 public immutable seasonId;

    // Address of the redemption contract that can burn tokens
    address public redeemContract;

    event RedeemContractSet(
        address indexed oldContract,
        address indexed newContract
    );
    event Redeemed(address indexed account, uint256 amount, bytes data);

    /**
     * @dev Constructor
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _seasonId Season identifier
     * @param _initialOwner Initial owner address
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _seasonId,
        address _initialOwner
    ) ERC20(_name, _symbol) Ownable(_initialOwner) {
        seasonId = _seasonId;
    }

    /**
     * @dev Set the redemption contract address
     * @param _redeemContract Address of the redemption contract
     */
    function setRedeemContract(address _redeemContract) external onlyOwner {
        address oldContract = redeemContract;
        redeemContract = _redeemContract;
        emit RedeemContractSet(oldContract, _redeemContract);
    }

    /**
     * @dev Mint tokens to an account (only owner)
     * @param to Recipient of the tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Burn tokens from an account (only owner or redeem contract)
     * @param from Account to burn from
     * @param amount Amount of tokens to burn
     * @param data Additional data for the redemption
     */
    function burn(address from, uint256 amount, bytes calldata data) external {
        require(
            msg.sender == owner() || msg.sender == redeemContract,
            "Not authorized to burn"
        );

        _burn(from, amount);
        emit Redeemed(from, amount, data);
    }

    /**
     * @dev Override transfer function to prevent transfers
     */
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        revert("Transfers are disabled for vouchers");
    }

    /**
     * @dev Override transferFrom function to prevent transfers
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        revert("Transfers are disabled for vouchers");
    }

    /**
     * @dev Override approve function to only allow approvals to the redeem contract
     */
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        require(
            spender == redeemContract || spender == address(this),
            "Approvals are only allowed for the redeem contract"
        );

        return super.approve(spender, amount);
    }
}
