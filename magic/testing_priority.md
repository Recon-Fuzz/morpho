# Testing Priority for MorphoTargets Functions

These functions are ranked in order of how they should be implemented in unit tests. When creating unit tests for `CryticToFoundry` test each of the functions in this order.

1. `morpho_accrueInterest`
   - market must be created first

2. `morpho_setAuthorization`
   - no prerequisite

3. `morpho_setAuthorizationWithSig`
   - no prerequisite

4. `morpho_supply`
   - market must be created first

5. `morpho_supplyCollateral`
   - market must be created first

6. `morpho_flashLoan`
   - no prerequisite

7. `morpho_withdraw`
   - supply must be called first
   - authorization required if withdrawing on behalf of another user

8. `morpho_borrow`
   - market must be created first
   - collateral must be supplied first
   - authorization required if borrowing on behalf of another user

9. `morpho_repay`
   - borrow must be called first

10. `morpho_withdrawCollateral`
    - supplyCollateral must be called first
    - authorization required if withdrawing on behalf of another user

11. `morpho_liquidate`
    - market must be created first
    - borrow must be called first
    - position must be unhealthy (collateral value < borrowed amount * LLTV)