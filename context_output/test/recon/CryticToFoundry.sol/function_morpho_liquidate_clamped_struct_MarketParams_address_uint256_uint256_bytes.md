# Function: morpho_liquidate_clamped(struct MarketParams,address,uint256,uint256,bytes)

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `morpho_liquidate_clamped(struct MarketParams,address,uint256,uint256,bytes)`
- **Visibility**: public
- **Source Range**: 7666:1009:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped liquidate - attempts to create and liquidate unhealthy positions
function morpho_liquidate_clamped(MarketParams memory marketParams, address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data) public asActor() {
    marketParams = defaultMarketParams;
    address[] memory actors = _getActors();
    borrower = actors[uint256(uint160(borrower)) % actors.length];
    (, uint256 borrowShares, uint256 collateral) = morpho.position(defaultMarketId, borrower);
    if ((borrowShares == 0) || (collateral == 0)) return;
    seizedAssets = (seizedAssets % ((collateral / 10) + 1)) + 1;
    repaidShares = 0;
    morpho_liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
}
```

## Related Implementations

### _getActors()

- **Kind**: internal
- **Source**: 1250:103:29
- **Link**: `lib/setup-helpers/src/ActorManager.sol:ActorManager:_getActors()`

```solidity
/// @notice Returns all actors being used
function _getActors() internal view returns (address[] memory) {
    return _actors.values();
}
```

### values(struct EnumerableSet.AddressSet)

- **Kind**: internal
- **Source**: 10259:300:31
- **Link**: `lib/setup-helpers/src/EnumerableSet.sol:EnumerableSet:values(struct EnumerableSet.AddressSet)`

```solidity
///  @dev Return the entire set in an array
///  WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
///  to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
///  this function has an unbounded cost, and using it as part of a state-changing function may render the function
///  uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
function values(AddressSet storage set) internal view returns (address[] memory) {
    bytes32[] memory store = _values(set._inner);
    address[] memory result;
    /// @solidity memory-safe-assembly
    assembly {
        result := store
    }
    return result;
}
```

### _values(struct EnumerableSet.Set)

- **Kind**: internal
- **Source**: 5570:109:31
- **Link**: `lib/setup-helpers/src/EnumerableSet.sol:EnumerableSet:_values(struct EnumerableSet.Set)`

```solidity
///  @dev Return the entire set in an array
///  WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
///  to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
///  this function has an unbounded cost, and using it as part of a state-changing function may render the function
///  uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
function _values(Set storage set) private view returns (bytes32[] memory) {
    return set._values;
}
```

### morpho_liquidate(struct MarketParams,address,uint256,uint256,bytes)

- **Kind**: internal
- **Source**: 11898:247:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_liquidate(struct MarketParams,address,uint256,uint256,bytes)`

```solidity
function morpho_liquidate(MarketParams memory marketParams, address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data) public asActor() {
    morpho.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
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

## External Calls

- **Morpho::position(Id,address)**

## State Variable Reads

- **_actors** (`struct EnumerableSet.AddressSet`)
- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_liquidate_clamped(struct MarketParams,address,uint256,uint256,bytes) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActors() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  │ └─ [2] ⚙️ FUNCTION: EnumerableSet.values(struct EnumerableSet.AddressSet) (NodeID: 2)
  │     💬 Args: [_actors]
  │     👁️  Def: internal
  │   └─ [3] ⚙️ FUNCTION: EnumerableSet._values(struct EnumerableSet.Set) (NodeID: 3)
  │       💬 Args: [set._inner]
  │       👁️  Def: private
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_liquidate(struct MarketParams,address,uint256,uint256,bytes) (NodeID: 4)
  │   💬 Args: [marketParams, borrower, seizedAssets, repaidShares, data]
  │   👁️  Def: public
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 5)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 6)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  └─ [1] 🔒 MODIFIER: Setup.asActor() (NodeID: 7)
      💬 Args: [no args]
    └─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 8)
        💬 Args: [no args]
        👁️  Def: internal
```

## Documentation

### Function Documentation

@notice Clamped liquidate - attempts to create and liquidate unhealthy positions
