# Echidna Dictionary Entries for Morpho Blue

This document contains important constant values that Echidna should prioritize when fuzzing. These values are derived from the Morpho Blue protocol constants and boundaries.

## Important Numeric Values

### LLTV (Loan-to-Value) Values
- `0` - Zero LLTV (no collateral requirement)
- `0.5e18` (500000000000000000) - 50% LLTV
- `0.8e18` (800000000000000000) - 80% LLTV (default in tests)
- `0.99e18` (990000000000000000) - 99% LLTV (maximum safe)
- `1e18` (1000000000000000000) - 100% LLTV (full value)
- `1.01e18` (1010000000000000000) - Over 100% (should fail)

### Fee Values
- `0` - No fee
- `0.1e18` (100000000000000000) - 10% fee
- `0.25e18` (250000000000000000) - 25% fee (maximum allowed)
- `0.5e18` (500000000000000000) - 50% fee (should fail)
- `1e18` (1000000000000000000) - 100% fee (should fail)

### Oracle Price Scale
- `1e36` (1000000000000000000000000000000000000) - ORACLE_PRICE_SCALE constant
- `0` - Zero price (edge case)
- `1e35` (100000000000000000000000000000000000) - 0.1x price scale
- `1e37` (10000000000000000000000000000000000000) - 10x price scale

### Amount Boundaries (based on initial balance type(uint88).max)
- `0` - Zero amount
- `1` - Minimum amount
- `309485009821345068724781055` - type(uint88).max
- `3094850098213450687247810` - type(uint88).max / 100 (MAX_SUPPLY_AMOUNT)
- `309485009821345068724781` - type(uint88).max / 1000 (MAX_BORROW_AMOUNT)

### Actor Addresses (from Setup.sol)
- `0x0000000000000000000000000000000000000100` - Actor 1
- `0x0000000000000000000000000000000000000200` - Actor 2

### Special Addresses
- `0x0000000000000000000000000000000000000000` - Zero address
- Contract address of Morpho (deployed at runtime)
- Contract address of loanToken (deployed at runtime)
- Contract address of collateralToken (deployed at runtime)
- Contract address of oracle (deployed at runtime)
- Contract address of irm (deployed at runtime)

### Percentage/Ratio Values
- `0` - 0%
- `1e17` (100000000000000000) - 10%
- `5e17` (500000000000000000) - 50%
- `8e17` (800000000000000000) - 80%
- `9e17` (900000000000000000) - 90%
- `1e18` (1000000000000000000) - 100%

### Edge Case Values
- `1` - Minimum non-zero
- `2` - Small value for modulo operations
- `10` - Small divisor
- `100` - Common divisor
- `1000` - Common divisor
- `type(uint128).max` (340282366920938463463374607431768211455)
- `type(uint256).max` (115792089237316195423570985008687907853269984665640564039457584007913129639935)

## Important Market Parameters

### Default Market Configuration
The default market in tests uses:
- loanToken: Deployed ERC20Mock
- collateralToken: Deployed ERC20Mock
- oracle: Deployed OracleMock with price = ORACLE_PRICE_SCALE
- irm: Deployed IrmMock
- lltv: 0.8e18 (80%)

### Enabled LLTVs in Setup
- `0`
- `0.5e18` (500000000000000000)
- `0.8e18` (800000000000000000)

### Enabled IRMs in Setup
- `address(0)` - Zero interest
- `address(irm)` - Mock IRM

## Boolean Values
- `true`
- `false`

## Empty/Default Values
- `hex""` - Empty bytes
- Empty MarketParams struct

## Usage Notes

These values should be added to Echidna's dictionary to help it find edge cases more quickly. The fuzzer will prioritize trying these values before random ones, which can significantly improve coverage of critical paths.

To use these in Echidna, they would typically be added via the `dictionaryFile` configuration option, though Echidna's current version may not support all these formats directly. This document serves as a reference for understanding critical values in the system.
