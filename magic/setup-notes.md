# Setup Implementation Notes

## Overview

The `Setup.sol` file at `/Users/nican0r/Documents/Morpho/morpho/test/recon/Setup.sol` was implemented correctly in Phase 1 and required **no modifications** during Phase 2 testing.

## Setup Configuration

The setup deploys and configures all necessary contracts for fuzzing:

### 1. Actors
```solidity
_addActor(address(0x100)); // Actor 1
_addActor(address(0x200)); // Actor 2
```
- Default actor is the contract itself (address(this))
- Two additional actors are added for multi-party testing
- All actors receive token balances and approvals

### 2. Tokens
```solidity
loanToken = _newAsset(18);      // MockERC20 for lending
collateralToken = _newAsset(18); // MockERC20 for collateral
```
- Both tokens use 18 decimals
- Created via `AssetManager._newAsset()`
- Automatically minted to all actors

### 3. Oracle
```solidity
oracle = new OracleMock();
oracle.setPrice(ORACLE_PRICE_SCALE); // 1e36 = 1:1 price ratio
```
- Deployed with 1:1 price ratio (collateral:loan)
- Price can be modified in tests to simulate market conditions
- Used by Morpho for health checks and liquidations

### 4. Interest Rate Model
```solidity
irm = new IrmMock();
```
- Provides borrow rate calculations
- Called by Morpho during interest accrual
- Enabled in Morpho configuration

### 5. Morpho Protocol
```solidity
morpho = new Morpho(address(this)); // Owner is the test contract
```
- Deployed with test contract as owner
- Allows admin functions to be called with `asAdmin` modifier
- Core protocol contract for all lending operations

### 6. Morpho Configuration
```solidity
morpho.enableIrm(address(0));     // Enable zero address IRM
morpho.enableIrm(address(irm));   // Enable mock IRM
morpho.enableLltv(0);              // Enable zero LLTV
morpho.enableLltv(DEFAULT_TEST_LLTV); // Enable 80% LLTV
```
- Enables required IRMs and LLTVs for market creation
- `DEFAULT_TEST_LLTV = 0.8 ether` (80%)
- Zero values enabled for edge case testing

### 7. Market Creation
```solidity
marketParams = MarketParams({
    loanToken: loanToken,
    collateralToken: collateralToken,
    oracle: address(oracle),
    irm: address(irm),
    lltv: DEFAULT_TEST_LLTV
});
marketId = marketParams.id();
morpho.createMarket(marketParams);
```
- Creates a single market with the configured parameters
- Market ID is computed and stored for reference
- Market is immediately usable for all operations

### 8. Token Approvals
```solidity
address[] memory approvalArray = new address[](1);
approvalArray[0] = address(morpho);
_finalizeAssetDeployment(_getActors(), approvalArray, type(uint88).max);
```
- Approves Morpho to spend both tokens for all actors
- Uses maximum safe approval amount (uint88.max)
- Enables all supply/borrow/collateral operations

## Why No Changes Were Needed

The original setup from Phase 1 was comprehensive and included:

1. ✅ **Correct Token Setup**: Both loan and collateral tokens with proper decimals
2. ✅ **Oracle Configuration**: Properly initialized with realistic price
3. ✅ **IRM Setup**: Interest rate model deployed and enabled
4. ✅ **Morpho Ownership**: Test contract as owner enables admin function testing
5. ✅ **Proper Permissions**: All necessary IRMs and LLTVs enabled
6. ✅ **Market Creation**: Valid market with all required parameters
7. ✅ **Actor Funding**: All actors receive tokens and approvals
8. ✅ **Multi-Actor Support**: Three actors for complex scenarios

## Modifiers

The setup provides two key modifiers:

### asAdmin
```solidity
modifier asAdmin {
    vm.prank(address(this));
    _;
}
```
- Used for owner-only functions (enableIrm, enableLltv, setFee, etc.)
- Pranks as the test contract (Morpho owner)

### asActor
```solidity
modifier asActor {
    vm.prank(address(_getActor()));
    _;
}
```
- Used for regular user functions
- Pranks as the currently selected actor
- Actor can be changed via `switchActor(index)`

## Constants

```solidity
uint8 internal constant DECIMALS = 18;
uint256 internal constant DEFAULT_TEST_LLTV = 0.8 ether; // 80% LLTV
```
- Standard 18 decimals for ERC20 tokens
- 80% LLTV provides realistic collateralization ratio

## Public Variables

All key contracts and parameters are stored as public variables:
- `morpho` - Main protocol contract
- `oracle` - Price oracle
- `irm` - Interest rate model
- `marketParams` - Market configuration
- `marketId` - Market identifier
- `loanToken` - ERC20 loan token address
- `collateralToken` - ERC20 collateral token address

These are accessible in all tests and target functions.

## Validation

Phase 2 testing validated that the setup:
1. ✅ Allows all target functions to execute successfully
2. ✅ Provides sufficient token balances for test scenarios
3. ✅ Enables multi-actor interactions
4. ✅ Supports admin operations
5. ✅ Handles edge cases (liquidations, price changes)

## Summary

The setup implementation is **complete and production-ready**. No modifications were needed during Phase 2, demonstrating that Phase 1's setup design was thorough and well-architected.

**Status**: ✅ Setup validated and confirmed working
**Modifications**: None required
**Coverage**: All 5 core contracts properly deployed and configured
