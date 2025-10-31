These functions are ranked in order of how they should be implemented in unit tests. When creating unit tests for `CryticToFoundry` test each of the functions in this order.

1. `morpho_accrueInterest`
   - no prerequisite
2. `morpho_setAuthorization`
   - no prerequisite
3. `morpho_supply`
   - no prerequisite
4. `morpho_supplyCollateral`
   - no prerequisite
5. `morpho_withdraw`
   - supply must be called first
6. `morpho_withdrawCollateral`
   - supplyCollateral must be called first
7. `morpho_flashLoan`
   - supply must be called first
8. `morpho_borrow`
   - supply must be called first
   - supplyCollateral must be called first
9. `morpho_repay`
   - borrow must be called first
10. `morpho_setAuthorizationWithSig`
    - requires valid signature
11. `morpho_liquidate`
    - borrow must be called first
    - position must be unhealthy
