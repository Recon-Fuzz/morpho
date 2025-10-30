# Function: onMorphoFlashLoan(uint256,bytes)

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `onMorphoFlashLoan(uint256,bytes)`
- **Visibility**: external
- **Source Range**: 669:241:60

## Implementation

```solidity
function onMorphoFlashLoan(uint256 assets, bytes calldata data) external {
    address token = abi.decode(data, (address));
    loanToken.approve(address(morpho), assets);
}
```

## External Calls

- **ERC20Mock::approve(address,uint256)**

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: CryticToFoundry.onMorphoFlashLoan(uint256,bytes) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: external
```

## Documentation

### Interface Documentation

@notice Callback called when a flash loan occurs.
 @dev The callback is called only if data is not empty.
 @param assets The amount of assets that was flash loaned.
 @param data Arbitrary data passed to the `flashLoan` function.
