// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RedemptionToken.sol";
import "../src/VoucherRedeemContract.sol";
import "../src/TapAntsVoucher.sol";

contract SetupRedemptionToken is Script {
    function run() external {
        // Deployment parameters
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address initialOwner = 0xeB8B62c7D8DbC3AB3B1103ce74551Fe5240c8F53;

        // Get the previously deployed contract addresses from environment variables
        // You'll need to set these after running the first deployment script
        address voucherAddress = 0x4223f47b1EB3bDB97d0117Ae50e2cC65309c22AE;
        address redeemContractAddress = 0x6cD3B9C6a28851377FCf305D3C269C328797Cc5E;

        // Load the existing contracts
        TapAntsVoucher voucher = TapAntsVoucher(voucherAddress);
        VoucherRedeemContract redeemContract = VoucherRedeemContract(
            redeemContractAddress
        );

        // Log setup information
        console.log("Setting up Redemption Token");
        console.log("Initial Owner:", initialOwner);
        console.log("Voucher Address:", voucherAddress);
        console.log("Redeem Contract Address:", redeemContractAddress);

        // Deploy the redemption token
        RedemptionToken redemptionToken = new RedemptionToken(
            "Tap Ants Token",
            "ANTS",
            initialOwner
        );

        // Set the redemption token in the redeem contract
        redeemContract.setRedemptionToken(
            voucherAddress,
            address(redemptionToken)
        );

        // Mint some redemption tokens to the redeem contract
        // For example, mint 1,000,000 tokens (with 18 decimals)
        uint256 mintAmount = 1_000_000 * 10 ** 18;
        redemptionToken.mint(redeemContractAddress, mintAmount);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log deployment result
        console.log("RedemptionToken deployed at:", address(redemptionToken));

        // Additional deployment info
        console.log("Verifying deployment...");
        console.log("Redemption Token Name:", redemptionToken.name());
        console.log("Redemption Token Symbol:", redemptionToken.symbol());
        console.log("Redemption Token Owner:", redemptionToken.owner());
        console.log(
            "Redemption Token Balance of Redeem Contract:",
            redemptionToken.balanceOf(redeemContractAddress) / 10 ** 18
        );
        console.log(
            "Redemption Token set for Voucher:",
            redeemContract.redemptionTokens(voucherAddress)
        );
    }
}
