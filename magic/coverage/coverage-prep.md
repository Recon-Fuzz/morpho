# Coverage Preparation - Phase 1

## Build Information

**Build Info File:** `/Users/nican0r/Documents/Morpho/morpho/out/build-info/ce43039dd13b17db.json`

## Context Analysis - Morpho Contract External Calls

This document analyzes the external calls made by the Morpho contract to identify all touched contracts that need coverage.

### Primary Contract: Morpho.sol

**Location:** `/Users/nican0r/Documents/Morpho/morpho/src/Morpho.sol`

### External Dependencies (Interfaces)

The Morpho contract interacts with the following external interfaces:

#### 1. IOracle Interface
**Purpose:** Price oracle for collateral valuation
**Methods Called:**
- `price()` - Returns the price of collateral in terms of loan token (lines 361, 518)

**Usage in Morpho:**
- Line 361: In `liquidate()` - Gets collateral price to calculate liquidation incentive
- Line 518: In `_isHealthy()` - Gets collateral price to check position health

#### 2. IIrm Interface (Interest Rate Model)
**Purpose:** Calculate borrow interest rates based on market utilization
**Methods Called:**
- `borrowRate(MarketParams, Market)` - Returns the current borrow rate (lines 163, 488)

**Usage in Morpho:**
- Line 163: In `createMarket()` - Initializes stateful IRM
- Line 488: In `_accrueInterest()` - Gets current borrow rate for interest calculation

#### 3. IERC20 Interface
**Purpose:** ERC20 token transfers for loan and collateral tokens
**Methods Called (via SafeTransferLib):**
- `safeTransferFrom(address, address, uint256)` - Transfer tokens from user to Morpho
- `safeTransfer(address, uint256)` - Transfer tokens from Morpho to user

**Usage in Morpho:**
- Line 194: `supply()` - Transfer loan tokens from supplier
- Line 227: `withdraw()` - Transfer loan tokens to withdrawer
- Line 263: `borrow()` - Transfer loan tokens to borrower
- Line 295: `repay()` - Transfer loan tokens from repayer
- Line 319: `supplyCollateral()` - Transfer collateral from supplier
- Line 341: `withdrawCollateral()` - Transfer collateral to withdrawer
- Line 410: `liquidate()` - Transfer collateral to liquidator
- Line 414: `liquidate()` - Transfer loan tokens from liquidator
- Line 427: `flashLoan()` - Transfer tokens to flash loan receiver
- Line 431: `flashLoan()` - Transfer tokens back from flash loan receiver

#### 4. IMorphoCallbacks Interfaces
**Purpose:** Optional callback functions for protocol integrations
**Interfaces:**
- `IMorphoSupplyCallback` - Callback after supply (line 192)
- `IMorphoRepayCallback` - Callback after repay (line 293)
- `IMorphoSupplyCollateralCallback` - Callback after supply collateral (line 317)
- `IMorphoLiquidateCallback` - Callback after liquidation (line 412)
- `IMorphoFlashLoanCallback` - Callback during flash loan (line 429)

**Note:** These are optional callbacks (only called when `data.length > 0`) and may not need direct coverage in the core fuzzing campaign, but should be considered for integration testing.

### Internal Libraries

The Morpho contract uses the following libraries (these are linked at compile time):

1. **ConstantsLib** - Protocol constants (MAX_FEE, LIQUIDATION_CURSOR, etc.)
2. **UtilsLib** - Utility functions
3. **EventsLib** - Event definitions
4. **ErrorsLib** - Error definitions
5. **MathLib** - Math operations (WAD math)
6. **SharesMathLib** - Shares/assets conversion math
7. **MarketParamsLib** - Market parameters utilities
8. **SafeTransferLib** - Safe ERC20 transfers (wraps IERC20)

### Summary of External Contracts to Cover

Based on the external calls analysis, the following contracts need to be covered:

1. **Morpho.sol** - Main protocol contract
2. **OracleMock.sol** - Oracle implementation (calls to `IOracle.price()`)
3. **IrmMock.sol** - Interest rate model (calls to `IIrm.borrowRate()`)
4. **ERC20 tokens** - Loan and collateral tokens (calls to `IERC20.transfer/transferFrom`)
5. **Libraries** (internal, compiled into Morpho):
   - ConstantsLib
   - UtilsLib
   - MathLib
   - SharesMathLib
   - MarketParamsLib
   - SafeTransferLib
   - EventsLib
   - ErrorsLib

### Call Graph

```
Morpho.sol
├── IOracle (OracleMock)
│   └── price()
├── IIrm (IrmMock)
│   └── borrowRate(MarketParams, Market)
├── IERC20 (loanToken, collateralToken)
│   ├── safeTransferFrom() [via SafeTransferLib]
│   └── safeTransfer() [via SafeTransferLib]
└── IMorphoCallbacks (optional, for integrations)
    ├── onMorphoSupply()
    ├── onMorphoRepay()
    ├── onMorphoSupplyCollateral()
    ├── onMorphoLiquidate()
    └── onMorphoFlashLoan()
```

## Next Steps

Update `contracts-to-cover.md` with the complete list of contracts identified through this external calls analysis.
