# Function: morpho_supply_clamped(struct MarketParams,uint256,uint256,address,bytes)

**Contract**: [test/recon/CryticTester.sol/contract_CryticTester.md]

## Metadata

- **Contract**: CryticTester
- **Signature**: `morpho_supply_clamped(struct MarketParams,uint256,uint256,address,bytes)`
- **Visibility**: public
- **Source Range**: 981:1004:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped supply function - constrains amounts to valid ranges
function morpho_supply_clamped(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor() {
    marketParams = defaultMarketParams;
    if ((assets % 2) == 0) {
        assets = (assets % MAX_SUPPLY_AMOUNT) + 1;
        shares = 0;
    } else {
        assets = 0;
        shares = (shares % MAX_SUPPLY_AMOUNT) + 1;
    }
    if ((onBehalf == address(0)) || ((uint256(uint160(onBehalf)) % 2) == 0)) {
        onBehalf = _getActor();
    } else {
        address[] memory actors = _getActors();
        onBehalf = actors[uint256(uint160(onBehalf)) % actors.length];
    }
    morpho_supply(marketParams, assets, shares, onBehalf, data);
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

### morpho_supply(struct MarketParams,uint256,uint256,address,bytes)

- **Kind**: internal
- **Source**: 12735:217:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_supply(struct MarketParams,uint256,uint256,address,bytes)`

```solidity
function morpho_supply(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor() {
    morpho.supply(marketParams, assets, shares, onBehalf, data);
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

## State Variable Reads

- **MAX_SUPPLY_AMOUNT** (`uint256`)
- **_actor** (`address`)
- **_actors** (`struct EnumerableSet.AddressSet`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_supply_clamped(struct MarketParams,uint256,uint256,address,bytes) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActors() (NodeID: 2)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  │ └─ [2] ⚙️ FUNCTION: EnumerableSet.values(struct EnumerableSet.AddressSet) (NodeID: 3)
  │     💬 Args: [_actors]
  │     👁️  Def: internal
  │   └─ [3] ⚙️ FUNCTION: EnumerableSet._values(struct EnumerableSet.Set) (NodeID: 4)
  │       💬 Args: [set._inner]
  │       👁️  Def: private
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_supply(struct MarketParams,uint256,uint256,address,bytes) (NodeID: 5)
  │   💬 Args: [marketParams, assets, shares, onBehalf, data]
  │   👁️  Def: public
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 6)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 7)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  └─ [1] 🔒 MODIFIER: Setup.asActor() (NodeID: 8)
      💬 Args: [no args]
    └─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 9)
        💬 Args: [no args]
        👁️  Def: internal
```

## Documentation

### Function Documentation

@notice Clamped supply function - constrains amounts to valid ranges
