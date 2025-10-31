# Handlers Missing Coverage - Clamping Analysis

This file documents which handler functions require clamped versions to improve coverage during fuzzing.

## Date: October 30, 2025
## Purpose: Phase 4 - Identify handlers needing clamped versions

---

## Analysis Methodology

Handlers are identified as needing clamping if:
1. They have large input spaces (uint256) that make random fuzzing ineffective
2. They depend on preconditions (sufficient balance, shares, collateral, etc.)
3. They frequently revert without proper input constraints
4. The valid input range is a small subset of the total uint256 space

---

## User Function Handlers Requiring Clamping

### 1. morpho_supply
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- `assets` parameter: Random uint256 values will almost always exceed user's token balance
- `shares` parameter: Random values unlikely to correspond to meaningful amounts
- `onBehalf` address: Random addresses are not actors
**Clamping Needed:**
- Clamp `assets` to `IERC20(loanToken).balanceOf(actor)`
- Use `_getActor()` for `onBehalf`
- Set either `assets` or `shares` to 0 (exactlyOneZero requirement)

### 2. morpho_withdraw
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- `assets` parameter: Must not exceed user's supplied position
- `shares` parameter: Must not exceed user's supply shares
- `onBehalf` and `receiver` addresses: Should be actors for meaningful testing
- Requires authorization check
**Clamping Needed:**
- Clamp `assets` to withdrawable amount (total supply minus borrows)
- Clamp `shares` to `position[id][onBehalf].supplyShares`
- Use `_getActor()` for both `onBehalf` and `receiver`
- Set either `assets` or `shares` to 0

### 3. morpho_borrow
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- `assets` parameter: Limited by collateral value and available liquidity
- `shares` parameter: Must be meaningful in relation to market state
- Requires sufficient collateral to be healthy
- Limited by `totalSupplyAssets - totalBorrowAssets`
**Clamping Needed:**
- Clamp `assets` to available liquidity
- Use `_getActor()` for `onBehalf` and `receiver`
- Set either `assets` or `shares` to 0
- May need collateral prerequisite

### 4. morpho_repay
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- `assets` parameter: Should not exceed borrowed amount
- `shares` parameter: Limited to user's borrow shares
- `onBehalf` address: Should be an actor with existing borrow
**Clamping Needed:**
- Clamp `assets` to user's borrowed amount
- Clamp `shares` to `position[id][onBehalf].borrowShares`
- Use `_getActor()` for `onBehalf`
- Set either `assets` or `shares` to 0

### 5. morpho_supplyCollateral
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- `assets` parameter: Random values will exceed user's collateral token balance
- `onBehalf` address: Should be an actor
- Cannot be 0 (ZERO_ASSETS check)
**Clamping Needed:**
- Clamp `assets` to `IERC20(collateralToken).balanceOf(actor) + 1`
- Use `_getActor()` for `onBehalf`

### 6. morpho_withdrawCollateral
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- `assets` parameter: Limited by position's collateral and health factor
- Must maintain healthy position after withdrawal
- Requires authorization
- Cannot be 0 (ZERO_ASSETS check)
**Clamping Needed:**
- Clamp `assets` to `position[id][onBehalf].collateral`
- Use `_getActor()` for `onBehalf` and `receiver`
- Consider health factor constraints

### 7. morpho_liquidate
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- Requires finding an unhealthy position
- `seizedAssets` and `repaidShares`: One must be 0, other must be meaningful
- `borrower` address: Must be an actor with unhealthy position
- Complex preconditions make random fuzzing ineffective
**Clamping Needed:**
- Use `_getActor()` for `borrower`
- Clamp `seizedAssets` to `position[id][borrower].collateral`
- Clamp `repaidShares` to `position[id][borrower].borrowShares`
- Set either `seizedAssets` or `repaidShares` to 0
- May need helper to create unhealthy positions

### 8. morpho_flashLoan
**Location:** `test/recon/targets/MorphoTargets.sol`
**Issue:**
- `assets` parameter: Limited by Morpho's token balance
- `token` address: Should be loanToken or collateralToken
- Requires callback implementation (will revert without it)
- Cannot be 0 (ZERO_ASSETS check)
**Clamping Needed:**
- Set `token` to `loanToken` (from Setup)
- Clamp `assets` to `IERC20(token).balanceOf(address(morpho))`
- Note: Will still revert without callback, but useful for coverage

---

## Handlers NOT Requiring Clamping

### 9. morpho_accrueInterest
**Reason:** No amount parameters, only takes MarketParams which is already configured

### 10. morpho_setAuthorization
**Reason:** Simple boolean flag, address can be actor, minimal reverts expected

### 11. morpho_createMarket
**Reason:** Market already created in Setup, will revert with MARKET_ALREADY_CREATED (expected)

### 12. morpho_setAuthorizationWithSig
**Reason:** Will revert with invalid signature (expected), signature generation not implemented

---

## Admin Function Handlers

### Admin handlers are less critical for clamping because:
1. They are called with `asAdmin` modifier (fewer permission issues)
2. Most have simple validation (addresses, boolean flags)
3. Some will intentionally revert (ALREADY_SET) which is expected behavior

### morpho_setFee
**Possible Clamping:**
- Clamp `newFee` to `MAX_FEE` (0.25e18)
- Use `marketParams` from Setup

### morpho_enableIrm
**No Clamping Needed:** Address parameter, will revert if already enabled (expected)

### morpho_enableLltv
**Possible Clamping:**
- Clamp `lltv` to `WAD - 1` (must be < WAD)

### morpho_setFeeRecipient
**No Clamping Needed:** Address parameter, simple validation

### morpho_setOwner
**No Clamping Needed:** Address parameter, simple validation

---

## Summary: Functions Requiring Clamped Handlers

### High Priority (Core Functionality)
1. `morpho_supply` - Amount clamping critical
2. `morpho_withdraw` - Amount and shares clamping critical
3. `morpho_borrow` - Collateral and liquidity constraints
4. `morpho_repay` - Borrow shares/assets clamping
5. `morpho_supplyCollateral` - Balance clamping
6. `morpho_withdrawCollateral` - Collateral and health constraints

### Medium Priority (Complex Operations)
7. `morpho_liquidate` - Requires unhealthy position setup
8. `morpho_flashLoan` - Balance clamping (will still revert)

### Low Priority (Admin)
9. `morpho_setFee` - Simple bounds
10. `morpho_enableLltv` - Simple bounds

---

## Implementation Notes

For each clamped handler:
1. Function name should have `_clamped` suffix
2. Should call the unclamped handler after applying constraints
3. Use modulo operator with `+ 1` when maximum should be included
4. Remove unused parameters if they're explicitly set (e.g., recipient when using _getActor())
5. Use `_getActor()` for all user addresses
6. Set `data` to `bytes("")` for all callbacks
