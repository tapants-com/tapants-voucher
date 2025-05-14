// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TapAntsVoucher.sol";
import "../src/VoucherRedeemContract.sol";

contract DeployVoucherSystem is Script {
    function run() external {
        // Deployment parameters
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address initialOwner = 0xeB8B62c7D8DbC3AB3B1103ce74551Fe5240c8F53;
        uint256 seasonId = 1; // Season 1

        // Log deployment information
        console.log("Deploying Tap Ants Voucher System");
        console.log("Initial Owner:", initialOwner);
        console.log("Season ID:", seasonId);

        // Deploy the voucher token
        TapAntsVoucher voucher = new TapAntsVoucher(
            "Tap Ants Voucher Season 1",
            "vANTS",
            seasonId,
            initialOwner
        );

        // Deploy the redeem contract
        VoucherRedeemContract redeemContract = new VoucherRedeemContract(
            initialOwner
        );

        // Set the redeem contract in the voucher token
        // Note: This will only work if the script deployer is also the initialOwner
        // Otherwise, this step would need to be done separately by the owner
        if (msg.sender == initialOwner) {
            voucher.setRedeemContract(address(redeemContract));

            // Add the voucher to supported vouchers in the redeem contract
            redeemContract.setSupportedVoucher(address(voucher), true);
        }

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log deployment result
        console.log("TapAntsVoucher deployed at:", address(voucher));
        console.log(
            "VoucherRedeemContract deployed at:",
            address(redeemContract)
        );

        // Additional deployment info
        console.log("Verifying deployment...");
        console.log("Voucher Name:", voucher.name());
        console.log("Voucher Symbol:", voucher.symbol());
        console.log("Voucher Season ID:", voucher.seasonId());
        console.log("Voucher Owner:", voucher.owner());
        console.log("Voucher Redeem Contract:", voucher.redeemContract());
        console.log("Redeem Contract Owner:", redeemContract.owner());
        console.log(
            "Is Voucher Supported:",
            redeemContract.supportedVouchers(address(voucher))
        );
    }
}
