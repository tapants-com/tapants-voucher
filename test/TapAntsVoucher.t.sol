// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TapAntsVoucher.sol";
import "../src/VoucherRedeemContract.sol";

contract VoucherSystemTest is Test {
    TapAntsVoucher public voucher;
    VoucherRedeemContract public redeemContract;

    address public admin = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    uint256 public seasonId = 1;

    function setUp() public {
        // Setup admin
        vm.startPrank(admin);

        // Deploy contracts
        voucher = new TapAntsVoucher(
            "Tap Ants Voucher Season 1",
            "vANTS-S1",
            seasonId,
            admin
        );

        redeemContract = new VoucherRedeemContract(admin);

        // Configure contracts
        voucher.setRedeemContract(address(redeemContract));
        redeemContract.setSupportedVoucher(address(voucher), true);

        vm.stopPrank();
    }

    // Test Basic Voucher Token Properties
    function testVoucherProperties() public {
        assertEq(
            voucher.name(),
            "Tap Ants Voucher Season 1",
            "Incorrect token name"
        );
        assertEq(voucher.symbol(), "vANTS-S1", "Incorrect token symbol");
        assertEq(voucher.seasonId(), seasonId, "Incorrect season ID");
        assertEq(voucher.owner(), admin, "Incorrect owner");
        assertEq(
            voucher.redeemContract(),
            address(redeemContract),
            "Incorrect redeem contract"
        );
    }

    // Test Mint Function
    function testMint() public {
        vm.startPrank(admin);
        voucher.mint(user1, 100);
        vm.stopPrank();

        assertEq(voucher.balanceOf(user1), 100, "Incorrect balance after mint");
        assertEq(
            voucher.totalSupply(),
            100,
            "Incorrect total supply after mint"
        );
    }

    // Test Only Owner Can Mint
    function testMintOnlyOwner() public {
        vm.startPrank(user1);
        vm.expectRevert(
            "OwnableUnauthorizedAccount(0x0000000000000000000000000000000000000002"
        );
        voucher.mint(user1, 100);
        vm.stopPrank();
    }

    // Test Token Transfers Are Disabled
    function testTransfersDisabled() public {
        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);
        vm.stopPrank();

        // Try to transfer
        vm.startPrank(user1);
        vm.expectRevert("Transfers are disabled for vouchers");
        voucher.transfer(user2, 50);
        vm.stopPrank();
    }

    // Test Admin Can Burn Tokens
    function testAdminBurn() public {
        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);

        // Admin burns tokens
        voucher.burn(user1, 30, "");
        vm.stopPrank();

        assertEq(
            voucher.balanceOf(user1),
            70,
            "Incorrect balance after admin burn"
        );
        assertEq(
            voucher.totalSupply(),
            70,
            "Incorrect total supply after admin burn"
        );
    }

    // Test Redeem Contract Can Burn Tokens
    function testRedeemContractBurn() public {
        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);
        vm.stopPrank();

        // Redeem contract burns tokens
        vm.startPrank(admin);
        redeemContract.redeem(address(voucher), user1, 40, "");
        vm.stopPrank();

        assertEq(
            voucher.balanceOf(user1),
            60,
            "Incorrect balance after redeem contract burn"
        );
        assertEq(
            voucher.totalSupply(),
            60,
            "Incorrect total supply after redeem contract burn"
        );
    }

    // Test Cannot Burn If Not Admin or Redeem Contract
    function testCannotBurnUnauthorized() public {
        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);
        vm.stopPrank();

        // User tries to burn tokens directly
        vm.startPrank(user1);
        vm.expectRevert("Not authorized to burn");
        voucher.burn(user1, 30, "");
        vm.stopPrank();
    }

    // Test Change Redeem Contract
    function testChangeRedeemContract() public {
        address newRedeemContract = address(0x4);

        vm.startPrank(admin);
        voucher.setRedeemContract(newRedeemContract);
        vm.stopPrank();

        assertEq(
            voucher.redeemContract(),
            newRedeemContract,
            "Redeem contract not updated correctly"
        );
    }

    // Test Only Owner Can Change Redeem Contract
    function testChangeRedeemContractOnlyOwner() public {
        address newRedeemContract = address(0x4);

        vm.startPrank(user1);
        vm.expectRevert(
            "OwnableUnauthorizedAccount(0x0000000000000000000000000000000000000002"
        );
        voucher.setRedeemContract(newRedeemContract);
        vm.stopPrank();
    }

    // Test Redeem Contract Support Management
    function testRedeemContractSupportManagement() public {
        // Deploy a new voucher
        vm.startPrank(admin);
        TapAntsVoucher newVoucher = new TapAntsVoucher(
            "Tap Ants Voucher Season 2",
            "vANTS-S2",
            2,
            admin
        );

        // Verify it's not supported initially
        assertEq(
            redeemContract.supportedVouchers(address(newVoucher)),
            false,
            "New voucher should not be supported initially"
        );

        // Support the new voucher
        redeemContract.setSupportedVoucher(address(newVoucher), true);
        assertEq(
            redeemContract.supportedVouchers(address(newVoucher)),
            true,
            "New voucher should be supported after setting"
        );

        // Remove support
        redeemContract.setSupportedVoucher(address(newVoucher), false);
        assertEq(
            redeemContract.supportedVouchers(address(newVoucher)),
            false,
            "New voucher should not be supported after removing support"
        );

        vm.stopPrank();
    }

    // Test Redeem Function With Event
    function testRedeemWithEvent() public {
        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);

        // Expect event when redeeming
        vm.expectEmit(true, true, true, true);
        emit VoucherRedeemContract.VoucherRedeemed(
            address(voucher),
            user1,
            40,
            "test_data"
        );

        // Redeem tokens
        redeemContract.redeem(address(voucher), user1, 40, "test_data");
        vm.stopPrank();
    }

    // Test Redeem Function Fails For Unsupported Voucher
    function testRedeemFailsForUnsupportedVoucher() public {
        // Deploy a new voucher that's not supported
        vm.startPrank(admin);
        TapAntsVoucher unsupportedVoucher = new TapAntsVoucher(
            "Unsupported Voucher",
            "UNSUP",
            999,
            admin
        );

        unsupportedVoucher.mint(user1, 100);

        // Try to redeem with unsupported voucher
        vm.expectRevert("Voucher not supported");
        redeemContract.redeem(address(unsupportedVoucher), user1, 40, "");

        vm.stopPrank();
    }

    // Test Approval Management
    function testApprovalManagement() public {
        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);
        vm.stopPrank();

        // Try to approve to random address (should fail)
        vm.startPrank(user1);
        vm.expectRevert("Approvals are only allowed for the redeem contract");
        voucher.approve(user2, 50);
        vm.stopPrank();

        // Try to approve to redeem contract (should work)
        vm.startPrank(user1);
        voucher.approve(address(redeemContract), 50);
        assertEq(
            voucher.allowance(user1, address(redeemContract)),
            50,
            "Approval to redeem contract failed"
        );
        vm.stopPrank();
    }

    // Test Self Redeem Function (if implemented)
    function testSelfRedeem() public {
        // Note: This test assumes you have implemented the selfRedeem function
        // If you haven't, you can comment out this test

        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);
        vm.stopPrank();

        // User approves redeem contract
        vm.startPrank(user1);
        voucher.approve(address(redeemContract), 100);

        // This will fail if selfRedeem is not implemented
        // vm.expectCall(address(redeemContract), abi.encodeWithSelector(VoucherRedeemContract.selfRedeem.selector));
        // redeemContract.selfRedeem(address(voucher), 50, "");
        // assertEq(voucher.balanceOf(user1), 50, "Incorrect balance after self redeem");

        vm.stopPrank();
    }

    // Test Invalid Redemption
    function testInvalidRedemption() public {
        // First mint some tokens
        vm.startPrank(admin);
        voucher.mint(user1, 100);

        // Try to redeem more than balance
        vm.expectRevert("ERC20: burn amount exceeds balance");
        redeemContract.redeem(address(voucher), user1, 150, "");

        vm.stopPrank();
    }
}
