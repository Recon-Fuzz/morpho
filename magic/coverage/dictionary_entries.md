# Dictionary Entries for Morpho Fuzzing Campaign

This file documents all meaningful constants, values, and addresses that should be included in Echidna's dictionary to improve fuzzing effectiveness.

## Date: October 30, 2025
## Purpose: Phase 4 - Clamped Handler Implementation

---

## Protocol Constants (from ConstantsLib.sol)

### Fees
- `MAX_FEE = 0.25e18` (25% maximum fee)
- Fee range: `0` to `0.25e18`

### Oracle
- `ORACLE_PRICE_SCALE = 1e36` (standard price scale)

### Liquidation
- `LIQUIDATION_CURSOR = 0.3e18` (30%)
- `MAX_LIQUIDATION_INCENTIVE_FACTOR = 1.15e18` (115%)

### Math
- `WAD = 1e18` (standard 18-decimal fixed point unit)

---

## Setup Configuration Values (from Setup.sol)

### Market Configuration
- `DEFAULT_TEST_LLTV = 0.8 ether` (80% loan-to-value ratio)
- Alternative LLTV: `0` (zero LLTV enabled for testing)

### Decimals
- `DECIMALS = 18`

### Actor Addresses
- Actor 1: `0x100`
- Actor 2: `0x200`
- Setup contract (admin): `address(this)`

### Initial Balances
- `type(uint88).max` (maximum approval amount set in setup)

---

## Dynamic Values (from Market State)

### Market State Variables
These values are dynamic and should be read from the contract state:

#### Supply/Borrow Totals
- `market[id].totalSupplyAssets` - Total assets supplied
- `market[id].totalSupplyShares` - Total supply shares
- `market[id].totalBorrowAssets` - Total assets borrowed
- `market[id].totalBorrowShares` - Total borrow shares
- `market[id].fee` - Current market fee

#### Position Balances
- `position[id][actor].supplyShares` - User's supply shares
- `position[id][actor].borrowShares` - User's borrow shares
- `position[id][actor].collateral` - User's collateral amount

#### Token Balances
- `IERC20(loanToken).balanceOf(actor)` - Actor's loan token balance
- `IERC20(collateralToken).balanceOf(actor)` - Actor's collateral token balance
- `IERC20(loanToken).balanceOf(address(morpho))` - Morpho's loan token balance

---

## Market Parameters (from Setup.sol)

### MarketParams Structure
```solidity
MarketParams {
    loanToken: address,        // Setup: loanToken address
    collateralToken: address,  // Setup: collateralToken address
    oracle: address,           // Setup: address(oracle)
    irm: address,              // Setup: address(irm) or address(0)
    lltv: uint256             // Setup: DEFAULT_TEST_LLTV (0.8e18) or 0
}
```

### Enabled Values
- IRM addresses: `address(0)`, `address(irm)`
- LLTV values: `0`, `0.8e18`

---

## Special Addresses

### Zero Address
- `address(0)` - Used for various checks and as enabled IRM

### Contract Addresses (deployed during setup)
- `address(morpho)` - Morpho protocol contract
- `address(oracle)` - Oracle mock contract
- `address(irm)` - Interest rate model mock contract
- `loanToken` - ERC20 loan token address
- `collateralToken` - ERC20 collateral token address

---

## Boundary Values for Clamping

### For Supply/Withdraw Operations
- Minimum: `0` (will revert in most cases)
- Maximum: `IERC20(loanToken).balanceOf(actor)` for supply
- Maximum: `position[id][actor].supplyShares` converted to assets for withdraw

### For Collateral Operations
- Minimum: `0` (will revert)
- Maximum: `IERC20(collateralToken).balanceOf(actor)` for supply
- Maximum: `position[id][actor].collateral` for withdraw (with health check)

### For Borrow/Repay Operations
- Minimum: `0` (will revert)
- Maximum for borrow: Constrained by:
  - Available liquidity: `market[id].totalSupplyAssets - market[id].totalBorrowAssets`
  - Collateral value and LLTV
- Maximum for repay: `position[id][actor].borrowShares` converted to assets

### For Liquidation
- Target: Unhealthy positions where `collateral * price * lltv < borrowed assets * WAD`
- Seized assets: Limited by `position[borrower][id].collateral`
- Repaid shares: Limited by `position[borrower][id].borrowShares`

---

## Boolean Values

### Authorization
- `true` - Grant authorization
- `false` - Revoke authorization

### Current State Checks
- `isAuthorized[owner][authorized]` - Current authorization status
- `isIrmEnabled[irm]` - IRM enabled status
- `isLltvEnabled[lltv]` - LLTV enabled status

---

## Assets/Shares Input Patterns

According to Morpho's logic, exactly one of assets or shares must be zero:

### Valid Combinations
- `(assets: non-zero, shares: 0)` - Specify amount in assets
- `(assets: 0, shares: non-zero)` - Specify amount in shares
- Invalid: `(assets: non-zero, shares: non-zero)` - Will revert with INCONSISTENT_INPUT
- Invalid: `(assets: 0, shares: 0)` - Will revert with INCONSISTENT_INPUT

---

## Useful Derived Values

### Health Factor Calculation
```
healthFactor = (collateral * oraclePrice * lltv) / (borrowedAssets * ORACLE_PRICE_SCALE)
```

For liquidation:
- Healthy: `healthFactor >= WAD`
- Unhealthy (can liquidate): `healthFactor < WAD`

### Share Conversions
```
shares = assets * totalShares / totalAssets  (round down for supply/borrow)
assets = shares * totalAssets / totalShares  (round down for withdraw/repay)
```

---

## Clamping Strategy Summary

Based on these dictionary entries, clamped handlers should:

1. **Use actor addresses** from ActorManager (`_getActor()`)
2. **Clamp amounts** to available balances/shares
3. **Use valid MarketParams** from setup (already configured)
4. **Respect assets/shares exclusivity** (set one to 0)
5. **Stay within protocol limits** (MAX_FEE, MAX_LLTV, etc.)
6. **Use meaningful address values** (actors, contracts, address(0))

---

## Notes

- All clamping should use modulo operator with `+ 1` when maximum value should be included
- Prefer under-clamping (looser bounds) to over-clamping (tighter bounds)
- Use `_getActor()` for all user-related addresses
- Market parameters should generally use `marketParams` from Setup
- Empty bytes `bytes("")` should be used for callbacks (no callback implementation)
