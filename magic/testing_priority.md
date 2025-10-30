# Testing Priority List

These functions are ranked in order of how they should be implemented in unit tests. When creating unit tests for `CryticToFoundry` test each of the functions in this order.

1. `morpho_createMarket`
   - no prerequisite

2. `morpho_setAuthorization`
   - no prerequisite

3. `morpho_setAuthorizationWithSig`
   - no prerequisite

4. `morpho_supply`
   - no prerequisite

5. `morpho_supplyCollateral`
   - no prerequisite

6. `morpho_accrueInterest`
   - market must exist

7. `morpho_withdraw`
   - supply must be called first

8. `morpho_borrow`
   - supplyCollateral must be called first

9. `morpho_repay`
   - borrow must be called first

10. `morpho_withdrawCollateral`
    - supplyCollateral must be called first

11. `morpho_flashLoan`
    - supply must be called first

12. `morpho_liquidate`
    - supplyCollateral must be called first
    - borrow must be called first
    - position must be unhealthy

13. `morpho_supply_clamped`
    - no prerequisite

14. `morpho_supply_clamped_assetsOnly`
    - no prerequisite

15. `morpho_supplyCollateral_clamped`
    - no prerequisite

16. `morpho_setAuthorization_clamped`
    - no prerequisite

17. `morpho_accrueInterest_clamped`
    - market must exist

18. `morpho_withdraw_clamped`
    - supply must be called first

19. `morpho_borrow_clamped`
    - automatically supplies collateral if needed

20. `morpho_repay_clamped`
    - borrow must be called first

21. `morpho_withdrawCollateral_clamped`
    - supplyCollateral must be called first

22. `morpho_flashLoan_clamped`
    - supply must be called first

23. `morpho_liquidate_clamped`
    - requires unhealthy position

24. `workflow_supplyLoan_clamped`
    - no prerequisite

25. `workflow_supplyCollateralAndBorrow_clamped`
    - no prerequisite