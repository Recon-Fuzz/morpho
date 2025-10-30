# Contracts to Cover

This document lists all contracts that must be fully covered by the fuzzer. The list includes the core contracts deployed in Setup.sol and all contracts touched through external calls.

## Core Contracts

### Main Protocol Contract
- `Morpho.sol` - Main lending protocol contract that handles all core operations including supply, withdraw, borrow, repay, liquidate, and flash loans

## Library Contracts (Contain Business Logic)

### Critical Libraries
These libraries contain executable business logic and mathematical operations that are used throughout the protocol:

- `SafeTransferLib.sol` - Handles safe ERC20 token transfers with proper error checking
- `MarketParamsLib.sol` - Computes market identifiers from market parameters using keccak256
- `MathLib.sol` - Fixed-point arithmetic library with WAD-based calculations and Taylor series approximations
- `SharesMathLib.sol` - Manages share-to-asset conversions using virtual shares/assets pattern
- `UtilsLib.sol` - Utility functions including zero checks, min/max, safe casting, and zero-floor subtraction

## Supporting Libraries (Definition Only)

These libraries provide constants, events, and errors but do not contain executable logic requiring coverage:

- `ConstantsLib.sol` - Protocol constants (MAX_FEE, LIQUIDATION_CURSOR, etc.)
- `EventsLib.sol` - Event definitions
- `ErrorsLib.sol` - Error message strings

## Summary

**Total Contracts Requiring Full Coverage: 6**

1. Morpho.sol
2. SafeTransferLib.sol
3. MarketParamsLib.sol
4. MathLib.sol
5. SharesMathLib.sol
6. UtilsLib.sol

## Notes

- Mock contracts (ERC20Mock, OracleMock, IrmMock) are excluded as they are only used for testing
- Interface contracts (IIrm, IOracle, IERC20, IMorphoCallbacks) are excluded as they define external integrations
- The fuzzer should focus on achieving comprehensive coverage of all functions and branches in the 6 listed contracts
- Special attention should be paid to edge cases in mathematical operations and share calculations
