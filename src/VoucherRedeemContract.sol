// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./TapAntsVoucher.sol";

/**
 * @title VoucherRedeemContract
 * @dev Contract that handles redemption of voucher tokens in exchange for another token
 */
contract VoucherRedeemContract is Ownable {
    using SafeERC20 for IERC20;

    // Mapping of supported voucher tokens
    mapping(address => bool) public supportedVouchers;

    // Mapping of voucher token to its redemption token
    mapping(address => address) public redemptionTokens;

    event VoucherSupported(address indexed voucherToken, bool supported);
    event RedemptionTokenSet(
        address indexed voucherToken,
        address indexed redemptionToken
    );
    event VoucherRedeemed(
        address indexed voucherToken,
        address indexed account,
        uint256 amount,
        bytes data
    );

    /**
     * @dev Constructor
     * @param initialOwner Initial contract owner
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Set supported voucher token
     * @param voucherToken Address of voucher token
     * @param supported Whether the token is supported
     */
    function setSupportedVoucher(
        address voucherToken,
        bool supported
    ) external onlyOwner {
        supportedVouchers[voucherToken] = supported;
        emit VoucherSupported(voucherToken, supported);
    }

    /**
     * @dev Set the redemption token for a voucher token
     * @param voucherToken Address of voucher token
     * @param redemptionToken Address of the token to be issued on redemption
     */
    function setRedemptionToken(
        address voucherToken,
        address redemptionToken
    ) external onlyOwner {
        require(
            voucherToken != address(0),
            "Voucher token cannot be zero address"
        );
        require(
            redemptionToken != address(0),
            "Redemption token cannot be zero address"
        );

        redemptionTokens[voucherToken] = redemptionToken;
        emit RedemptionTokenSet(voucherToken, redemptionToken);
    }

    /**
     * @dev Admin function to redeem/burn voucher tokens and issue new tokens
     * @param voucherToken Address of voucher token to redeem
     * @param account Account to redeem from
     * @param amount Amount to redeem
     * @param data Additional data for redemption
     */
    function redeem(
        address voucherToken,
        address account,
        uint256 amount,
        bytes calldata data
    ) external onlyOwner {
        require(supportedVouchers[voucherToken], "Voucher not supported");
        address redemptionToken = redemptionTokens[voucherToken];
        require(redemptionToken != address(0), "Redemption token not set");

        // Check if this contract has enough redemption tokens
        require(
            IERC20(redemptionToken).balanceOf(address(this)) >= amount,
            "Insufficient redemption tokens in contract"
        );

        // Burn the voucher tokens
        TapAntsVoucher(voucherToken).burn(account, amount, data);

        // Transfer the redemption tokens to the account
        IERC20(redemptionToken).safeTransfer(account, amount);

        emit VoucherRedeemed(voucherToken, account, amount, data);
    }

    /**
     * @dev Self-service redemption function for users
     * @param voucherToken Address of voucher token to redeem
     * @param amount Amount to redeem
     * @param data Additional data for redemption
     */
    function selfRedeem(
        address voucherToken,
        uint256 amount,
        bytes calldata data
    ) external {
        require(supportedVouchers[voucherToken], "Voucher not supported");
        address redemptionToken = redemptionTokens[voucherToken];
        require(redemptionToken != address(0), "Redemption token not set");

        // Check if this contract has enough redemption tokens
        require(
            IERC20(redemptionToken).balanceOf(address(this)) >= amount,
            "Insufficient redemption tokens in contract"
        );

        // Burn the voucher tokens
        TapAntsVoucher(voucherToken).burn(msg.sender, amount, data);

        // Transfer the redemption tokens to the account
        IERC20(redemptionToken).safeTransfer(msg.sender, amount);

        emit VoucherRedeemed(voucherToken, msg.sender, amount, data);
    }

    /**
     * @dev Emergency withdrawal of redemption tokens in case of issues
     * @param token Token to withdraw
     * @param to Address to send tokens to
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }
}
