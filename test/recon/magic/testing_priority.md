These functions are ranked in order of how they should be implemented in unit tests. When creating unit tests for `CryticToFoundry` test each of the functions in this order.

1. `morpho_flashLoan`
   - no prerequisite

2. `morpho_setAuthorization`
   - no prerequisite

3. `morpho_setAuthorizationWithSig`
   - no prerequisite

4. `morpho_accrueInterest`
   - market must be created first

5. `morpho_supply`
   - market must be created first

6. `morpho_supplyCollateral`
   - market must be created first

7. `morpho_withdraw`
   - supply must be called first

8. `morpho_withdrawCollateral`
   - supplyCollateral must be called first

9. `morpho_repay`
   - borrow must be called first

10. `morpho_borrow`
    - market must be created first
    - supply must be called first (for liquidity)
    - supplyCollateral must be called first (for collateral)

11. `morpho_liquidate`
    - market must be created first
    - supply must be called first (for liquidity)
    - supplyCollateral must be called first (by borrower)
    - borrow must be called first (to create position)
    - position must become unhealthy (price change or high borrow)