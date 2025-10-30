# Coverage Preparation

## Build Info
- **Build Info File**: `/Users/nelsonpereira/Documents/GitHub/Auditing/Fuzzing/Recon_Fuzzing/Morpho/morpho-blue/out/build-info/429aa349c5ede8fa.json`
- **Sol-expand Command**: `sol-expand --extract-context /Users/nelsonpereira/Documents/GitHub/Auditing/Fuzzing/Recon_Fuzzing/Morpho/morpho-blue/out/build-info/429aa349c5ede8fa.json`

## Primary Contract from Setup.sol

### Core Contract Deployed
- `Morpho.sol` (line 49 in Setup.sol)

### Mock Contracts (Excluded)
- `ERC20Mock.sol` (lines 52-53)
- `OracleMock.sol` (line 60)
- `IrmMock.sol` (line 64)

## External Calls Analysis from Morpho.sol

### Interface Contracts Called
1. **IIrm** (Interest Rate Model Interface)
   - Called in `createMarket()` at line 163
   - Called in `_accrueInterest()` at line 488
   - Method: `borrowRate(MarketParams, Market)`

2. **IOracle** (Price Oracle Interface)
   - Called in `liquidate()` at line 361
   - Called in `_isHealthy()` at line 518
   - Method: `price()`

3. **IERC20** (ERC20 Token Interface)
   - Called throughout for token transfers
   - Methods: `safeTransfer()`, `safeTransferFrom()`
   - Used for both loanToken and collateralToken

4. **IMorphoCallbacks** (Callback Interfaces)
   - `IMorphoSupplyCallback` - line 192
   - `IMorphoRepayCallback` - line 293
   - `IMorphoSupplyCollateralCallback` - line 317
   - `IMorphoLiquidateCallback` - line 412
   - `IMorphoFlashLoanCallback` - line 429

### Library Dependencies (Used by Morpho)
1. **SafeTransferLib.sol** - Used for safe ERC20 operations
2. **MarketParamsLib.sol** - Used for market parameter hashing
3. **MathLib.sol** - Used for mathematical operations
4. **SharesMathLib.sol** - Used for shares calculations
5. **UtilsLib.sol** - Used for utility functions
6. **ConstantsLib.sol** - Constants definitions
7. **EventsLib.sol** - Event definitions
8. **ErrorsLib.sol** - Error definitions

## Contracts That Need Coverage

### Core Contracts
- `Morpho.sol` - Main protocol contract

### Library Contracts (Contain Business Logic)
- `SafeTransferLib.sol` - Token transfer logic
- `MarketParamsLib.sol` - Market parameter logic
- `MathLib.sol` - Mathematical operations
- `SharesMathLib.sol` - Shares calculation logic
- `UtilsLib.sol` - Utility functions

### Note on Constants and Events
- `ConstantsLib.sol`, `EventsLib.sol`, and `ErrorsLib.sol` are definition-only files
- They don't contain executable logic that needs fuzzing coverage
