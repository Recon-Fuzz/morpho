# Setup Notes for Morpho Blue Fuzzing

## Overview

The setup in `Setup.sol` configures the Morpho Blue protocol for fuzzing with all necessary contracts, permissions, and initial state.

## Setup Components

### 1. Actor Management
- **Actors Added**: 2 additional actors (0x100 and 0x200) plus the default actor (address(this))
- **Actor Configuration**:
  - Each actor receives initial balance: `type(uint88).max` (~3.09e26) for both loan and collateral tokens
  - All actors pre-approve Morpho contract for both tokens with max approval

### 2. Core Contracts Deployed

#### Morpho Protocol
- **Owner**: `address(this)` (the test contract)
- **Fee Recipient**: `address(this)`

#### Mock Tokens (ERC20Mock)
- **Loan Token**: Used for lending/borrowing
- **Collateral Token**: Used for collateral
- **Note**: Both tokens use `setBalance()` instead of mint functions
- **Asset Manager**: Both tokens registered via `_addAsset()`

#### Oracle (OracleMock)
- **Initial Price**: `ORACLE_PRICE_SCALE` (1e36)
- **Purpose**: Provides collateral valuation for LTV calculations

#### Interest Rate Model (IrmMock)
- **Type**: Mock IRM for testing
- **Flexibility**: Can be configured to return different borrow rates

### 3. Morpho Configuration

#### Enabled Interest Rate Models
1. `address(0)` - Zero interest rate (useful for simple testing)
2. `address(irm)` - Mock IRM

#### Enabled LLTVs (Loan-to-Value Ratios)
1. `0` - 0% LTV (no borrowing allowed)
2. `0.5e18` - 50% LTV
3. `0.8e18` - 80% LTV (used in default market)

### 4. Default Market Configuration

The setup creates a default market with these parameters:
- **Loan Token**: Deployed ERC20Mock
- **Collateral Token**: Deployed ERC20Mock
- **Oracle**: Deployed OracleMock
- **IRM**: Deployed IrmMock
- **LLTV**: 0.8e18 (80%)

This market is immediately created and available for use in all tests.

### 5. Modifiers

#### asAdmin
```solidity
modifier asAdmin {
    vm.prank(address(this));
    _;
}
```
Used for functions requiring owner privileges (enableIrm, enableLltv, setFee, setFeeRecipient, setOwner)

#### asActor
```solidity
modifier asActor {
    vm.prank(address(_getActor()));
    _;
}
```
Used for regular user functions (supply, borrow, withdraw, etc.)

## Key Design Decisions

### 1. Token Balances
- Used `type(uint88).max` to provide substantial balances without risking overflow
- This amount is large enough for extensive fuzzing operations

### 2. Pre-approvals
- All actors pre-approve Morpho for max amounts
- Eliminates approval-related reverts during fuzzing
- Focuses fuzzing on protocol logic rather than token mechanics

### 3. Multiple LLTVs
- Enables testing different risk profiles
- 0% for no-borrow scenarios
- 50% for conservative borrowing
- 80% for aggressive borrowing (used in default market)

### 4. Zero Interest Option
- `address(0)` as IRM provides zero interest
- Simplifies testing by removing interest accrual complexity when needed

## Setup Validation

The setup has been validated through comprehensive unit tests that verify:
1. All target functions can be called successfully
2. Actor switching works correctly
3. Market operations (supply, borrow, withdraw, repay, liquidate) function properly
4. Admin functions work with correct permissions
5. Flash loans work with proper liquidity and callbacks

## No Modifications Needed

The current setup is complete and requires no modifications. All 11 target functions from the testing priority list work correctly with the existing configuration.

## Setup Execution

The setup is called in `CryticToFoundry.setUp()`:
```solidity
function setUp() public {
    setup();
    targetContract(address(this));
}
```

This ensures the fuzzing environment is fully initialized before any test or fuzzing campaign runs.
