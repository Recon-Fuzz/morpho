# Function: test_morpho_liquidate()

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `test_morpho_liquidate()`
- **Visibility**: public
- **Source Range**: 8319:1083:60

## Implementation

```solidity
function test_morpho_liquidate() public {
    uint256 supplyAmount = 10000e18;
    uint256 collateralAmount = 10000e18;
    uint256 borrowAmount = 7000e18;
    morpho_supply(defaultMarketParams, supplyAmount, 0, _getActor(), hex"");
    switchActor(1);
    address borrower = _getActor();
    morpho_supplyCollateral(defaultMarketParams, collateralAmount, borrower, hex"");
    morpho_borrow(defaultMarketParams, borrowAmount, 0, borrower, borrower);
    oracle.setPrice(ORACLE_PRICE_SCALE / 2);
    switchActor(0);
    morpho_liquidate(defaultMarketParams, borrower, 0, 1e18, hex"");
}
```

## Related Implementations

### morpho_supply(struct MarketParams,uint256,uint256,address,bytes)

- **Kind**: internal
- **Source**: 12735:217:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_supply(struct MarketParams,uint256,uint256,address,bytes)`

```solidity
function morpho_supply(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor() {
    morpho.supply(marketParams, assets, shares, onBehalf, data);
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

### switchActor(uint256)

- **Kind**: internal
- **Source**: 680:83:66
- **Link**: `test/recon/targets/ManagersTargets.sol:ManagersTargets:switchActor(uint256)`

```solidity
/// @dev Start acting as another actor
function switchActor(uint256 entropy) public {
    _switchActor(entropy);
}
```

### _switchActor(uint256)

- **Kind**: internal
- **Source**: 2547:143:29
- **Link**: `lib/setup-helpers/src/ActorManager.sol:ActorManager:_switchActor(uint256)`

```solidity
/// @dev Expose this in the `TargetFunctions` contract to let the fuzzer switch actors
///    NOTE: We revert if the entropy is greater than the number of actors, for Halmos compatibility
///  @dev This may reduce fuzzing performance if using multiple actors, if so add explicitly clamped handlers to ManagersTargets using the index of all added actors
///  @notice Switches the current actor based on the entropy
///  @param entropy The entropy to choose a random actor in the array for switching
///  @return target The new active actor
function _switchActor(uint256 entropy) internal returns (address target) {
    target = _actors.at(entropy);
    _actor = target;
}
```

### at(struct EnumerableSet.AddressSet,uint256)

- **Kind**: internal
- **Source**: 9563:156:31
- **Link**: `lib/setup-helpers/src/EnumerableSet.sol:EnumerableSet:at(struct EnumerableSet.AddressSet,uint256)`

```solidity
///  @dev Returns the value stored at position `index` in the set. O(1).
///  Note that there are no guarantees on the ordering of values inside the
///  array, and it may change when more values are added or removed.
///  Requirements:
///  - `index` must be strictly less than {length}.
function at(AddressSet storage set, uint256 index) internal view returns (address) {
    return address(uint160(uint256(_at(set._inner, index))));
}
```

### _at(struct EnumerableSet.Set,uint256)

- **Kind**: internal
- **Source**: 4912:118:31
- **Link**: `lib/setup-helpers/src/EnumerableSet.sol:EnumerableSet:_at(struct EnumerableSet.Set,uint256)`

```solidity
///  @dev Returns the value stored at position `index` in the set. O(1).
///  Note that there are no guarantees on the ordering of values inside the
///  array, and it may change when more values are added or removed.
///  Requirements:
///  - `index` must be strictly less than {length}.
function _at(Set storage set, uint256 index) private view returns (bytes32) {
    return set._values[index];
}
```

### morpho_supplyCollateral(struct MarketParams,uint256,address,bytes)

- **Kind**: internal
- **Source**: 12958:213:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_supplyCollateral(struct MarketParams,uint256,address,bytes)`

```solidity
function morpho_supplyCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data) public asActor() {
    morpho.supplyCollateral(marketParams, assets, onBehalf, data);
}
```

### morpho_borrow(struct MarketParams,uint256,uint256,address,address)

- **Kind**: internal
- **Source**: 11387:220:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_borrow(struct MarketParams,uint256,uint256,address,address)`

```solidity
function morpho_borrow(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor() {
    morpho.borrow(marketParams, assets, shares, onBehalf, receiver);
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

## External Calls

- **OracleMock::setPrice(uint256)**

## State Variable Reads

- **_actor** (`address`)
- **_actors** (`struct EnumerableSet.AddressSet`)

## State Variable Writes

- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: CryticToFoundry.test_morpho_liquidate() (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_supply(struct MarketParams,uint256,uint256,address,bytes) (NodeID: 1)
  │   💬 Args: [defaultMarketParams, supplyAmount, 0, _getActor(), hex""]
  │   👁️  Def: public
  │ ├─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 4)
  │ │   💬 Args: [no args]
  │ │   👁️  Def: internal
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 2)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 3)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: ManagersTargets.switchActor(uint256) (NodeID: 5)
  │   💬 Args: [1]
  │   👁️  Def: public
  │ └─ [2] ⚙️ FUNCTION: ActorManager._switchActor(uint256) (NodeID: 6)
  │     💬 Args: [entropy]
  │     👁️  Def: internal
  │   └─ [3] ⚙️ FUNCTION: EnumerableSet.at(struct EnumerableSet.AddressSet,uint256) (NodeID: 7)
  │       💬 Args: [_actors, entropy]
  │       👁️  Def: internal
  │     └─ [4] ⚙️ FUNCTION: EnumerableSet._at(struct EnumerableSet.Set,uint256) (NodeID: 8)
  │         💬 Args: [set._inner, index]
  │         👁️  Def: private
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 9)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_supplyCollateral(struct MarketParams,uint256,address,bytes) (NodeID: 10)
  │   💬 Args: [defaultMarketParams, collateralAmount, borrower, hex""]
  │   👁️  Def: public
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 11)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 12)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_borrow(struct MarketParams,uint256,uint256,address,address) (NodeID: 13)
  │   💬 Args: [defaultMarketParams, borrowAmount, 0, borrower, borrower]
  │   👁️  Def: public
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 14)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 15)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: ManagersTargets.switchActor(uint256) (NodeID: 16)
  │   💬 Args: [0]
  │   👁️  Def: public
  │ └─ [2] ⚙️ FUNCTION: ActorManager._switchActor(uint256) (NodeID: 17)
  │     💬 Args: [entropy]
  │     👁️  Def: internal
  │   └─ [3] ⚙️ FUNCTION: EnumerableSet.at(struct EnumerableSet.AddressSet,uint256) (NodeID: 18)
  │       💬 Args: [_actors, entropy]
  │       👁️  Def: internal
  │     └─ [4] ⚙️ FUNCTION: EnumerableSet._at(struct EnumerableSet.Set,uint256) (NodeID: 19)
  │         💬 Args: [set._inner, index]
  │         👁️  Def: private
  └─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_liquidate(struct MarketParams,address,uint256,uint256,bytes) (NodeID: 20)
      💬 Args: [defaultMarketParams, borrower, 0, 1e18, hex""]
      👁️  Def: public
    └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 21)
        💬 Args: [no args]
      └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 22)
          💬 Args: [no args]
          👁️  Def: internal
```
