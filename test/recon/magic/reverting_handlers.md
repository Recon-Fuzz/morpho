# Reverting Handlers

This document tracks target functions that have justified revert reasons (i.e., functions that are expected to revert in normal testing scenarios).

## Summary

No functions revert with justified reasons. All 11 target functions from the testing priority list can be successfully called and tested:

1. `morpho_flashLoan` - Passes when liquidity is available and callback is implemented
2. `morpho_setAuthorization` - Passes for any actor
3. `morpho_setAuthorizationWithSig` - Passes with valid signature (reverts with invalid signature, but this is expected behavior)
4. `morpho_accrueInterest` - Passes when market exists
5. `morpho_supply` - Passes when market exists and actor has balance
6. `morpho_supplyCollateral` - Passes when market exists and actor has balance
7. `morpho_withdraw` - Passes when supply exists
8. `morpho_withdrawCollateral` - Passes when collateral exists
9. `morpho_repay` - Passes when borrow position exists
10. `morpho_borrow` - Passes when liquidity and collateral exist
11. `morpho_liquidate` - Passes when position is unhealthy

## Admin Functions

The following functions were moved to `AdminTargets` as they require owner privileges:
- `morpho_enableIrm` - Requires owner to enable interest rate models
- `morpho_enableLltv` - Requires owner to enable loan-to-value ratios
- `morpho_setFee` - Requires owner to set market fees
- `morpho_setFeeRecipient` - Requires owner to set fee recipient
- `morpho_setOwner` - Requires owner to transfer ownership

These functions use the `asAdmin` modifier instead of `asActor` to ensure they are called with owner privileges.
