# Remaining Uncovered Functions and Branches

This document tracks functions and code branches that are not yet fully covered by the fuzzer.

## Coverage Report Analyzed
- File: `/Users/nelsonpereira/Documents/GitHub/Auditing/Fuzzing/Recon_Fuzzing/Morpho/morpho-blue/echidna/covered.1761814662.txt`
- Date: 2025-10-30

## Morpho.sol

### Critical Uncovered Branches

1. **liquidate() - Bad Debt Handling Branch**
   - Lines: 393-402 (in coverage report)
   - Description: The bad debt handling logic that executes when `position[id][borrower].collateral == 0`
   - Impact: This is a critical edge case for full liquidations where the borrower has no collateral left but still has debt
   - Code path: When a borrower is fully liquidated and their collateral reaches 0, this branch handles the remaining debt

2. **liquidate() - Else Branch for seizedAssets Calculation**
   - Lines: 377-380 (in coverage report)
   - Description: The branch that calculates `seizedAssets` when `repaidShares` is provided instead of `seizedAssets`
   - Impact: This tests the alternative liquidation calculation path
   - Code path: When liquidator provides `repaidShares` (instead of `seizedAssets`), this branch calculates how much collateral to seize

3. **_accrueInterest() - Fee Calculation Branch**
   - Lines: 494-502 (in coverage report)
   - Description: The fee calculation and distribution logic when `market[id].fee != 0`
   - Impact: This tests the protocol fee mechanism
   - Code path: When a market has a non-zero fee set, this branch calculates and distributes fees to the feeRecipient

### Non-Critical Uncovered Functions

4. **extSloads()**
   - Lines: 544-556 (in coverage report)
   - Description: View function for reading arbitrary storage slots
   - Impact: Low priority - this is a utility function for external storage reads
   - Note: This is a view function and doesn't affect state, lower priority for coverage

## Library Contracts

### All Libraries Fully Covered
- **MarketParamsLib.sol**: All functions covered ✓
- **MathLib.sol**: All functions covered ✓
- **SafeTransferLib.sol**: All functions covered ✓
- **SharesMathLib.sol**: All functions covered ✓
- **UtilsLib.sol**: All functions covered ✓

## Summary

**Total Uncovered Items: 4**
- Critical branches: 3
- Non-critical functions: 1

**Priority Order for Coverage:**
1. liquidate() - Bad Debt Handling Branch (highest priority - critical edge case)
2. liquidate() - Else Branch for seizedAssets Calculation (high priority - alternative calculation path)
3. _accrueInterest() - Fee Calculation Branch (medium priority - protocol fee mechanism)
4. extSloads() (low priority - view function only)

## Notes
- Admin-only functions (setOwner, enableIrm, enableLltv, setFee, setFeeRecipient) have some coverage from test setup but are not the focus of fuzzing
- All core user-facing functions (supply, withdraw, borrow, repay, supplyCollateral, withdrawCollateral) are fully covered
- The main gap is in edge case branches within the liquidate function and fee handling
