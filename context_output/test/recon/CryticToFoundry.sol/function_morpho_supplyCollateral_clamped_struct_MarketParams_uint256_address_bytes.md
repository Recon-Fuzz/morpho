# Function: morpho_supplyCollateral_clamped(struct MarketParams,uint256,address,bytes)

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `morpho_supplyCollateral_clamped(struct MarketParams,uint256,address,bytes)`
- **Visibility**: public
- **Source Range**: 3219:552:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped supply collateral function
function morpho_supplyCollateral_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data) public asActor() {
    marketParams = defaultMarketParams;
    assets = (assets % MAX_COLLATERAL_AMOUNT) + 1;
    address actor = _getActor();
    if ((onBehalf == address(0)) || ((uint256(uint160(onBehalf)) % 3) == 0)) {
        onBehalf = actor;
    }
    morpho_supplyCollateral(marketParams, assets, onBehalf, data);
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

### morpho_supplyCollateral(struct MarketParams,uint256,address,bytes)

- **Kind**: internal
- **Source**: 12958:213:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_supplyCollateral(struct MarketParams,uint256,address,bytes)`

```solidity
function morpho_supplyCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data) public asActor() {
    morpho.supplyCollateral(marketParams, assets, onBehalf, data);
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

- **MAX_COLLATERAL_AMOUNT** (`uint256`)
- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_supplyCollateral_clamped(struct MarketParams,uint256,address,bytes) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_supplyCollateral(struct MarketParams,uint256,address,bytes) (NodeID: 2)
  │   💬 Args: [marketParams, assets, onBehalf, data]
  │   👁️  Def: public
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 3)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 4)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  └─ [1] 🔒 MODIFIER: Setup.asActor() (NodeID: 5)
      💬 Args: [no args]
    └─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 6)
        💬 Args: [no args]
        👁️  Def: internal
```

## Documentation

### Function Documentation

@notice Clamped supply collateral function
