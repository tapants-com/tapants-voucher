# Tap Ants Voucher System

A Solidity-based voucher redemption system built using Foundry. This system enables the creation and management of non-transferable voucher tokens that can be redeemed for actual ERC20 tokens.

## Overview

The Tap Ants Voucher System consists of three main contracts:

1. **TapAntsVoucher**: A non-transferable ERC20 token that represents vouchers for a specific season.
2. **RedemptionToken**: A standard ERC20 token that users receive when they redeem their vouchers.
3. **VoucherRedeemContract**: A contract that manages the redemption process.

## Contract Architecture

### TapAntsVoucher

A non-transferable ERC20 token that:
- Has a seasonId to identify different voucher seasons
- Disables all regular transfers (cannot be sent from user to user)
- Can only be burned by the owner or the redemption contract
- Can only approve the redemption contract to spend tokens

### RedemptionToken

A standard ERC20 token that:
- Is minted by the owner and sent to the redemption contract
- Is distributed to users when they redeem their vouchers
- Represents the actual value token of the system (ANTS)

### VoucherRedeemContract

A management contract that:
- Keeps track of supported voucher tokens
- Maps voucher tokens to their corresponding redemption tokens
- Allows users to redeem their vouchers for redemption tokens
- Allows the admin to redeem vouchers on behalf of users

## Deployment Information

The contracts have been deployed to the Sepolia testnet with the following addresses:

- **TapAntsVoucher**: `0x4223f47b1EB3bDB97d0117Ae50e2cC65309c22AE`
- **VoucherRedeemContract**: `0x6cD3B9C6a28851377FCf305D3C269C328797Cc5E`
- **RedemptionToken**: `0x8f71a7503284c69eb200605b5ab11fabc555c865`

## How to Use

### Prerequisites

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation.html)
2. Clone this repository

```bash
git clone https://github.com/tapants-com/tapants-voucher.git
```

3. Install dependencies

```bash
forge install
```

### Configuration

Create a `.env` file with your private key:

```
PRIVATE_KEY=your_private_key_here
```

### Deployment

#### 1. Deploy the Voucher System

This script deploys both the TapAntsVoucher and VoucherRedeemContract:

```bash
forge script script/DeployVoucherSystem.s.sol --rpc-url <your-rpc-url> --broadcast --verify
```

Take note of the deployed contract addresses from the console output.

#### 2. Deploy the Redemption Token

After deploying the voucher system, set the voucher and redeem contract addresses in the `SetupRedemptionToken.s.sol` script or use the existing addresses, then run:

```bash
forge script script/SetupRedemptionToken.s.sol --rpc-url <your-rpc-url> --broadcast --verify
```

### Interacting with the Contracts

#### For Administrators

1. **Minting Vouchers**

```bash
cast send --private-key $PRIVATE_KEY \
  $VOUCHER_ADDRESS \
  "mint(address,uint256)" \
  $USER_ADDRESS \
  1000000000000000000 \
  --rpc-url <your-rpc-url>
```

2. **Supporting a Voucher**

```bash
cast send --private-key $PRIVATE_KEY \
  $REDEEM_CONTRACT_ADDRESS \
  "setSupportedVoucher(address,bool)" \
  $VOUCHER_ADDRESS \
  true \
  --rpc-url <your-rpc-url>
```

3. **Setting a Redemption Token for a Voucher**

```bash
cast send --private-key $PRIVATE_KEY \
  $REDEEM_CONTRACT_ADDRESS \
  "setRedemptionToken(address,address)" \
  $VOUCHER_ADDRESS \
  $REDEMPTION_TOKEN_ADDRESS \
  --rpc-url <your-rpc-url>
```

4. **Admin Redemption**

```bash
cast send --private-key $PRIVATE_KEY \
  $REDEEM_CONTRACT_ADDRESS \
  "redeem(address,address,uint256,bytes)" \
  $VOUCHER_ADDRESS \
  $USER_ADDRESS \
  1000000000000000000 \
  0x \
  --rpc-url <your-rpc-url>
```

#### For Users

1. **Check Voucher Balance**

```bash
cast call $VOUCHER_ADDRESS "balanceOf(address)" $USER_ADDRESS --rpc-url <your-rpc-url>
```

2. **Approve the Redemption Contract**

```bash
cast send --private-key $USER_PRIVATE_KEY \
  $VOUCHER_ADDRESS \
  "approve(address,uint256)" \
  $REDEEM_CONTRACT_ADDRESS \
  1000000000000000000 \
  --rpc-url <your-rpc-url>
```

3. **Self-Redeem Vouchers**

```bash
cast send --private-key $USER_PRIVATE_KEY \
  $REDEEM_CONTRACT_ADDRESS \
  "selfRedeem(address,uint256,bytes)" \
  $VOUCHER_ADDRESS \
  1000000000000000000 \
  0x \
  --rpc-url <your-rpc-url>
```

4. **Check Redemption Token Balance**

```bash
cast call $REDEMPTION_TOKEN_ADDRESS "balanceOf(address)" $USER_ADDRESS --rpc-url <your-rpc-url>
```

## Key Features

1. **Season-Based Vouchers**: Each voucher is tied to a specific season ID, allowing for season-specific rewards.
2. **Non-Transferable**: Vouchers cannot be transferred between users, preventing secondary markets.
3. **Dual Redemption Methods**: Vouchers can be redeemed by administrators or by users themselves.
4. **Flexible Redemption**: The system supports customizable redemption logic through the data parameter.

## Security Considerations

- Only the contract owner can mint vouchers and redemption tokens
- Only the owner or the redemption contract can burn vouchers
- Vouchers cannot be transferred between users, preventing unauthorized trading
- The emergency withdrawal function allows recovery of tokens in case of issues

## License

This project is licensed under the MIT License.
