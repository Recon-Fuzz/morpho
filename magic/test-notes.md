# Phase 2 Test Implementation Notes

## Overview
This document describes the unit tests implemented in Phase 2 to validate the fuzzing setup for the Morpho Blue protocol. All tests are implemented in `test/recon/CryticToFoundry.sol`.

## Test Coverage Summary
- Total Functions Tested: 11/11 (100%)
- Total Tests: 35
- Pass Rate: 35/35 (100%)

## Function Coverage

### 1. morpho_accrueInterest
**Tests: 3**
- `test_accrueInterest_revertsOnNonExistentMarket`: Verifies that accruing interest on a non-existent market reverts
- `test_accrueInterest_updatesTimestamp`: Confirms that accruing interest updates the lastUpdate timestamp
- `test_accrueInterest_noChangeWithoutBorrows`: Validates that with no borrows, supply and borrow amounts remain unchanged after accruing interest

**Setup Required**: Market must be created first (done in Setup contract)

### 2. morpho_setAuthorization
**Tests: 4**
- `test_setAuthorization_setsCorrectState`: Verifies authorization can be set to true and false
- `test_setAuthorization_emitsEvent`: Confirms SetAuthorization event is emitted
- `test_setAuthorization_revertsOnDuplicate`: Validates that setting the same authorization twice reverts
- `test_setAuthorization_doesNotAffectOtherUsers`: Ensures authorization is user-specific

**Setup Required**: None

### 3. morpho_setAuthorizationWithSig (NEW IN PHASE 2)
**Tests: 4**
- `test_setAuthorizationWithSig_setsCorrectState`: Verifies EIP-712 signature authorization works correctly
- `test_setAuthorizationWithSig_revertsOnExpiredDeadline`: Validates that expired signatures revert
- `test_setAuthorizationWithSig_revertsOnWrongNonce`: Confirms that incorrect nonces revert
- `test_setAuthorizationWithSig_revertsOnInvalidSignature`: Ensures invalid signatures revert

**Setup Required**:
- Uses vm.sign() to create valid EIP-712 signatures
- Requires SigUtils helper library for proper EIP-712 encoding

**Implementation Details**:
- Private keys are generated using vm.addr()
- Signatures are created using SigUtils.getTypedDataHash() with morpho.DOMAIN_SEPARATOR()
- Authorization struct includes: authorizer, authorized, isAuthorized, nonce, deadline

### 4. morpho_supply
**Tests: 4**
- `test_supply_increasesUserShares`: Verifies supply increases user's supply shares
- `test_supply_increasesTotalSupply`: Confirms supply increases total market supply
- `test_supply_revertsWithBothParams`: Validates that supplying with both assets and shares reverts
- `test_supply_revertsOnZeroAddress`: Ensures supplying to zero address reverts

**Setup Required**: Market must be created, tokens must be minted to user

### 5. morpho_supplyCollateral
**Tests: 3**
- `test_supplyCollateral_increasesUserCollateral`: Verifies collateral supply increases user's position
- `test_supplyCollateral_revertsOnZeroAmount`: Validates zero amount reverts
- `test_supplyCollateral_revertsOnZeroAddress`: Ensures zero address reverts

**Setup Required**: Market must be created, collateral tokens must be minted to user

### 6. morpho_flashLoan
**Tests: 2**
- `test_flashLoan_revertsOnZeroAmount`: Validates zero amount reverts
- `test_flashLoan_preservesBalance`: Confirms flash loans preserve contract balance (no fees)

**Setup Required**:
- Requires FlashLoanBorrower helper contract
- Helper implements onMorphoFlashLoan callback

### 7. morpho_withdraw
**Tests: 3**
- `test_withdraw_decreasesUserShares`: Verifies withdrawal decreases user's supply shares
- `test_withdraw_revertsWithoutAuthorization`: Validates unauthorized withdrawals revert
- `test_withdraw_transfersTokens`: Confirms tokens are transferred to receiver

**Setup Required**: User must have supplied first

### 8. morpho_borrow
**Tests: 3**
- `test_borrow_increasesUserBorrowShares`: Verifies borrow increases user's borrow shares
- `test_borrow_revertsWithoutCollateral`: Validates borrowing without collateral reverts
- `test_borrow_revertsWithoutAuthorization`: Ensures unauthorized borrowing reverts

**Setup Required**:
- Market must have liquidity (supplied by other users)
- Borrower must have collateral

### 9. morpho_repay
**Tests: 2**
- `test_repay_decreasesUserBorrowShares`: Verifies repayment decreases borrow shares
- `test_repay_anyoneCanRepay`: Confirms anyone can repay on behalf of a borrower

**Setup Required**: Borrower must have an active borrow position

### 10. morpho_withdrawCollateral
**Tests: 3**
- `test_withdrawCollateral_decreasesUserCollateral`: Verifies collateral withdrawal decreases position
- `test_withdrawCollateral_revertsWithoutAuthorization`: Validates unauthorized withdrawals revert
- `test_withdrawCollateral_revertsIfUnhealthy`: Ensures withdrawal that would make position unhealthy reverts

**Setup Required**: User must have supplied collateral first

### 11. morpho_liquidate (NEW IN PHASE 2)
**Tests: 4**
- `test_liquidate_liquidatesUnhealthyPosition`: Verifies liquidation works on unhealthy positions
- `test_liquidate_revertsOnHealthyPosition`: Validates liquidating healthy positions reverts
- `test_liquidate_revertsOnZeroAmount`: Ensures zero amount reverts
- `test_liquidate_realizesBadDebt`: Confirms bad debt is realized when collateral is insufficient

**Setup Required**:
- Borrower must have an active borrow with collateral
- Position must be made unhealthy by manipulating oracle price
- Liquidator must have loan tokens to repay debt

**Implementation Details**:
- Unhealthy positions are created by dropping oracle price (oracle.setPrice(ORACLE_PRICE_SCALE / 10))
- Bad debt scenario uses extreme price swings (high price for borrow, crash for liquidation)
- Tests verify both seized collateral and repaid amounts

## Test Pattern Structure

All tests follow this general pattern:

```solidity
function test_<function>_<scenario>() public {
    // 1. Setup: Create necessary state (supply liquidity, mint tokens, etc.)

    // 2. Execute: Call the target function or setup state

    // 3. Assert: Verify expected outcomes
}
```

## Key Testing Techniques Used

1. **State Verification**: Using morpho.position() and morpho.market() to verify state changes
2. **Event Testing**: Using vm.expectEmit() to verify events are emitted correctly
3. **Revert Testing**: Using vm.expectRevert() to test error conditions
4. **Access Control**: Using vm.startPrank() and vm.stopPrank() to test multi-user scenarios
5. **Oracle Manipulation**: Using oracle.setPrice() to create unhealthy positions for liquidation
6. **EIP-712 Signatures**: Using vm.sign() and SigUtils for signature-based authorization

## Helper Contracts

### FlashLoanBorrower
- Implements onMorphoFlashLoan callback
- Used to test flash loan functionality
- Automatically approves Morpho to pull back borrowed tokens

## Dependencies

The tests depend on:
- Foundry's Test framework (vm.* functions)
- SigUtils library for EIP-712 signature creation
- Mock contracts (ERC20Mock, OracleMock, IrmMock) from the Setup
- Helper contracts defined in the same file

## Running the Tests

```bash
# Run all tests
forge test --match-contract CryticToFoundry -vv

# Run specific test
forge test --match-test test_liquidate_liquidatesUnhealthyPosition -vvvv

# Run with detailed traces
forge test --match-contract CryticToFoundry -vvvv --decode-internal
```

## Notes for Future Agents

1. **Do not modify Setup.setup() in CryticToFoundry**: The setup() function should only be modified in the Setup contract
2. **Use target functions**: Always call functions defined in TargetFunctions or inherited contracts, never call morpho.* directly in tests
3. **Multi-step operations**: Many operations require setup (e.g., liquidation needs unhealthy position, borrow needs collateral)
4. **Oracle price**: Default is ORACLE_PRICE_SCALE (1e36), manipulate for unhealthy positions
5. **Authorization patterns**: Some functions (withdraw, withdrawCollateral, borrow on behalf) require authorization

## Test Execution Results

All 35 tests pass successfully:
- Compilation: Successful with 1 warning (unused variable in test_liquidate_realizesBadDebt)
- Execution Time: ~14ms
- Gas Usage: Tests range from ~15k to ~475k gas
