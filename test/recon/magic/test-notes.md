# Test Notes for Morpho Blue Fuzzing Setup

## Overview

This document describes how the unit tests for the Morpho Blue fuzzing setup work. All 11 target functions from the testing priority list have been successfully tested and pass.

## Test Structure

The tests are implemented in `/Users/nelsonpereira/Documents/GitHub/Auditing/Fuzzing/Recon_Fuzzing/Morpho/morpho-blue/test/recon/CryticToFoundry.sol` and follow the priority order specified in `testing_priority.md`.

## Test Details

### 1. test_morpho_flashLoan()
**Prerequisites**: Requires liquidity in the Morpho contract
**Setup**:
- Supplies 10,000 tokens to provide liquidity
- Implements `IMorphoFlashLoanCallback.onMorphoFlashLoan()` to handle the flash loan callback
- Approves the flash loaned assets for repayment in the callback

**Key Learning**: Flash loans in Morpho require:
1. Available liquidity in the protocol
2. Implementation of the flash loan callback
3. Proper approval of assets for repayment

### 2. test_morpho_setAuthorization()
**Prerequisites**: None
**Setup**: Uses one of the actors from the actor list
**Verification**: Checks authorization status using `morpho.isAuthorized()`

### 3. test_morpho_setAuthorizationWithSig()
**Prerequisites**: None
**Setup**: Creates Authorization struct with invalid signature
**Note**: Uses try-catch since invalid signatures will revert (expected behavior)

### 4. test_morpho_accrueInterest()
**Prerequisites**: Market must exist (created in setup)
**Setup**: No additional setup needed, uses `defaultMarketParams`

### 5. test_morpho_supply()
**Prerequisites**: Market must exist
**Setup**: Supplies 1,000 tokens
**Verification**: Checks that supply shares > 0 using `morpho.position()`

### 6. test_morpho_supplyCollateral()
**Prerequisites**: Market must exist
**Setup**: Supplies 1,000 collateral tokens
**Verification**: Checks that collateral > 0 using `morpho.position()`

### 7. test_morpho_withdraw()
**Prerequisites**: Must have existing supply position
**Setup**:
- Supplies 1,000 tokens first
- Then withdraws 500 tokens
**Verification**: Checks that supply shares remain > 0

### 8. test_morpho_withdrawCollateral()
**Prerequisites**: Must have existing collateral position
**Setup**:
- Supplies 1,000 collateral tokens first
- Then withdraws 500 collateral tokens
**Verification**: Checks that collateral remains > 0

### 9. test_morpho_repay()
**Prerequisites**: Must have existing borrow position
**Setup**:
1. Default actor supplies 10,000 tokens for liquidity
2. Switch to actor 1
3. Actor 1 supplies 10,000 collateral tokens
4. Actor 1 borrows 1,000 tokens
5. Actor 1 repays 500 tokens
**Verification**: Checks that borrow shares remain > 0

### 10. test_morpho_borrow()
**Prerequisites**: Requires market, liquidity, and collateral
**Setup**:
1. Default actor supplies 10,000 tokens for liquidity
2. Switch to actor 1
3. Actor 1 supplies 10,000 collateral tokens
4. Actor 1 borrows 1,000 tokens
**Verification**: Checks that borrow shares > 0

### 11. test_morpho_liquidate()
**Prerequisites**: Requires unhealthy borrow position
**Setup**:
1. Default actor supplies 10,000 tokens for liquidity
2. Switch to actor 1 (borrower)
3. Actor 1 supplies 10,000 collateral tokens
4. Actor 1 borrows 7,000 tokens (close to 80% LTV)
5. Oracle price is dropped by 50% to make position unhealthy
6. Switch to actor 0 (liquidator)
7. Liquidate the unhealthy position

**Key Learning**: To create an unhealthy position for liquidation:
- Borrow close to the maximum LTV (80% in default market)
- Manipulate oracle price to drop collateral value
- This makes collateral value insufficient to cover debt

## Actor Management

The tests use the actor management system:
- `_getActor()`: Returns current actor
- `switchActor(index)`: Switches to actor at given index
- `_getActors()`: Returns array of all actors

Default actor is `address(this)` (the test contract), and additional actors are at indices 0 and 1.

## Position Verification

Position data is retrieved using tuple destructuring:
```solidity
(uint256 supplyShares, uint128 borrowShares, uint128 collateral) = morpho.position(marketId, actor);
```

## Market Parameters

Tests use `defaultMarketParams` configured in setup with:
- Loan Token: ERC20Mock
- Collateral Token: ERC20Mock
- Oracle: OracleMock (price set to ORACLE_PRICE_SCALE = 1e36)
- IRM: IrmMock
- LLTV: 0.8e18 (80% loan-to-value ratio)

## Admin Functions

The following functions require owner privileges and have been moved to `AdminTargets`:
- `morpho_enableIrm()`
- `morpho_enableLltv()`
- `morpho_setFee()`
- `morpho_setFeeRecipient()`
- `morpho_setOwner()`

These use the `asAdmin` modifier which pranks as `address(this)` (the owner).

## Test Execution

All tests pass successfully:
```bash
forge test --match-contract CryticToFoundry -vv
```

Result: 12 tests passed (11 target functions + 1 empty test_crytic)
