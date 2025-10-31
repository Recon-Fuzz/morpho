# Phase 1: Contract Analysis and Scaffolding Requirements

## Core Contract for Invariant Testing

### 1. Morpho (src/Morpho.sol)
**Status:** Target functions scaffolded in `test/recon/targets/MorphoTargets.sol`

The Morpho contract is the main lending protocol contract with the following key functions:
- Market creation and management
- Supply/withdraw of loan and collateral assets
- Borrow/repay operations
- Flash loans
- Liquidations
- Authorization management
- Fee management
- Interest accrual

**Target Functions Scaffolded (17 functions):**
- morpho_accrueInterest
- morpho_borrow
- morpho_createMarket
- morpho_enableIrm
- morpho_enableLltv
- morpho_flashLoan
- morpho_liquidate
- morpho_repay
- morpho_setAuthorization
- morpho_setAuthorizationWithSig
- morpho_setFee
- morpho_setFeeRecipient
- morpho_setOwner
- morpho_supply
- morpho_supplyCollateral
- morpho_withdraw
- morpho_withdrawCollateral

## Dependency Contracts (Mocked)

### 1. IOracle - Price Oracle
**Mock:** `src/mocks/OracleMock.sol` (ALREADY EXISTS)
- Simple price oracle with settable price
- Used for collateral valuation in markets

### 2. IIrm - Interest Rate Model
**Mock:** `src/mocks/IrmMock.sol` (ALREADY EXISTS)
- Simple utilization-based interest rate model
- Calculates borrow rates based on market utilization

### 3. IERC20 - ERC20 Tokens
**Mock:** `src/mocks/ERC20Mock.sol` (ALREADY EXISTS)
- Used for both loan tokens and collateral tokens
- Integrated with AssetManager via MockERC20

## Additional Target Functions

### ManagersTargets (test/recon/targets/ManagersTargets.sol)
Handles asset and actor management:
- switchActor - Switch between test actors
- switch_asset - Switch between test assets
- add_new_asset - Deploy new ERC20 tokens
- asset_approve - Token approvals
- asset_mint - Mint tokens for testing

### AdminTargets (test/recon/targets/AdminTargets.sol)
Empty template for admin-specific target functions (if needed)

## Scaffolding Status

✅ **Core Contract:** Morpho - Fully scaffolded
✅ **Mocks:** All required mocks (Oracle, IRM, ERC20) exist
✅ **Manager Functions:** Asset and Actor management scaffolded
✅ **Target Files:** Properly structured

## Next Steps for Phase 2

Phase 2 should focus on:
1. Deploying mock contracts in Setup.sol
2. Creating at least one valid market with:
   - Loan token (ERC20Mock)
   - Collateral token (ERC20Mock)
   - Oracle (OracleMock)
   - IRM (IrmMock)
   - Valid LLTV value
3. Initializing actors with token balances
4. Setting up approvals for Morpho contract
5. Enabling the IRM and LLTV in Morpho
