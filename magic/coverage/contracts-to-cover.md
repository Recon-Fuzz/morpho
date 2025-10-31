# Contracts to Cover - Phase 1

This file contains the exhaustive list of all contracts that the fuzzer must always be able to cover.

## Analysis Sources

1. **Setup Contract:** `/Users/nican0r/Documents/Morpho/morpho/test/recon/Setup.sol`
2. **External Calls Analysis:** `/Users/nican0r/Documents/Morpho/morpho/magic/coverage/coverage-prep.md`

## Core Contracts (from Setup.sol)

Based on the `Setup` contract deployment:

### Main Protocol Contract
- `src/Morpho.sol` - Main lending protocol contract (deployed at line 62)
  - All external functions including supply, borrow, withdraw, repay, liquidate, flashLoan, etc.

## External Dependencies (Touched Contracts)

Based on external calls analysis from `coverage-prep.md`:

### 1. Oracle Implementation
- `src/mocks/OracleMock.sol` - Price oracle mock (deployed at line 55)
  - **Called by:** Morpho.liquidate() and Morpho._isHealthy()
  - **Method:** `price()` - Returns collateral price in terms of loan token

### 2. Interest Rate Model
- `src/mocks/IrmMock.sol` - Interest rate model mock (deployed at line 59)
  - **Called by:** Morpho.createMarket() and Morpho._accrueInterest()
  - **Method:** `borrowRate(MarketParams, Market)` - Returns current borrow rate

### 3. ERC20 Token Implementations
ERC20 tokens deployed via AssetManager's `_newAsset(DECIMALS)`:
- **Loan Token** (line 51)
  - **Called by:** All supply/withdraw/borrow/repay/liquidate/flashLoan operations
  - **Methods:** `transfer()`, `transferFrom()` (via SafeTransferLib)

- **Collateral Token** (line 52)
  - **Called by:** All supplyCollateral/withdrawCollateral/liquidate operations
  - **Methods:** `transfer()`, `transferFrom()` (via SafeTransferLib)

Note: The actual ERC20 implementation comes from the AssetManager's `_newAsset` method which uses MockERC20.

## Internal Libraries (Compiled into Morpho)

These libraries are linked at compile-time and their code coverage is included in Morpho.sol coverage:

1. **ConstantsLib** - Protocol constants (MAX_FEE, LIQUIDATION_CURSOR, etc.)
2. **UtilsLib** - Utility functions
3. **MathLib** - Math operations (WAD math)
4. **SharesMathLib** - Shares/assets conversion math
5. **MarketParamsLib** - Market parameters utilities
6. **SafeTransferLib** - Safe ERC20 transfers (wraps IERC20)
7. **EventsLib** - Event definitions
8. **ErrorsLib** - Error definitions

## Complete Coverage List

### Priority 1: Core Protocol
1. ✅ `src/Morpho.sol` - Main protocol with all functions

### Priority 2: External Dependencies (Always Called)
2. ✅ `src/mocks/OracleMock.sol` - Oracle for price feeds
3. ✅ `src/mocks/IrmMock.sol` - Interest rate model
4. ✅ **Loan Token (ERC20)** - Asset transfers for lending
5. ✅ **Collateral Token (ERC20)** - Asset transfers for collateral

### Priority 3: Libraries (Internal, coverage tracked via Morpho)
- ConstantsLib
- UtilsLib
- MathLib
- SharesMathLib
- MarketParamsLib
- SafeTransferLib
- EventsLib
- ErrorsLib

### Optional: Callback Interfaces (Integration Testing)
These are optional callbacks and not required for core fuzzing but useful for integration testing:
- IMorphoSupplyCallback
- IMorphoRepayCallback
- IMorphoSupplyCollateralCallback
- IMorphoLiquidateCallback
- IMorphoFlashLoanCallback

## Call Graph

```
Morpho.sol (PRIMARY TARGET)
├── OracleMock.sol (MUST COVER)
│   └── price()
├── IrmMock.sol (MUST COVER)
│   └── borrowRate(MarketParams, Market)
├── Loan Token ERC20 (MUST COVER)
│   ├── transfer()
│   └── transferFrom()
└── Collateral Token ERC20 (MUST COVER)
    ├── transfer()
    └── transferFrom()
```

## Phase 1 Completion Criteria

- [x] Identify all contracts deployed in Setup.sol
- [x] Analyze external calls in Morpho.sol
- [x] Document all touched contracts
- [x] Create exhaustive coverage list
- [x] Categorize by priority

## Next Phase

Phase 2 will focus on ensuring all target functions in `MorphoTargets.sol` can successfully execute and reach the identified contracts for maximum coverage.
