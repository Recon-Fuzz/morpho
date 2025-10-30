# Function: workflow_supplyLoan_clamped(uint256)

**Contract**: [test/recon/CryticTester.sol/contract_CryticTester.md]

## Metadata

- **Contract**: CryticTester
- **Signature**: `workflow_supplyLoan_clamped(uint256)`
- **Visibility**: public
- **Source Range**: 10952:201:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Supply loan tokens workflow
function workflow_supplyLoan_clamped(uint256 assets) public asActor() {
    assets = (assets % MAX_SUPPLY_AMOUNT) + 1;
    morpho.supply(defaultMarketParams, assets, 0, _getActor(), hex"");
}
```

## Related Implementations

### _getActor()

- **Kind**: internal
- **Source**: 1115:83:29
- **Link**: `lib/setup-helpers/src/ActorManager.sol:ActorManager:_getActor()`

```solidity
/// @notice Returns the current active actor
function _getActor() internal view returns (address) {
    return _actor;
}
```

### asActor()

- **Kind**: modifier
- **Source**: 3899:75:62
- **Link**: `test/recon/Setup.sol:Setup:asActor()`

```solidity
modifier asActor() {
    vm.prank(address(_getActor()));
    _;
}
```

## External Calls

- **Morpho::supply(struct MarketParams,uint256,uint256,address,bytes)**

## State Variable Reads

- **MAX_SUPPLY_AMOUNT** (`uint256`)
- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.workflow_supplyLoan_clamped(uint256) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  └─ [1] 🔒 MODIFIER: Setup.asActor() (NodeID: 2)
      💬 Args: [no args]
    └─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 3)
        💬 Args: [no args]
        👁️  Def: internal
```

## Documentation

### Function Documentation

@notice Supply loan tokens workflow
