# Function: morpho_withdrawCollateral_clamped(struct MarketParams,uint256,address,address)

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `morpho_withdrawCollateral_clamped(struct MarketParams,uint256,address,address)`
- **Visibility**: public
- **Source Range**: 3851:966:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped withdraw collateral - only withdraws safe amounts
function morpho_withdrawCollateral_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor() {
    marketParams = defaultMarketParams;
    address actor = _getActor();
    (, uint256 borrowShares, uint256 collateral) = morpho.position(defaultMarketId, actor);
    if (collateral == 0) return;
    if (borrowShares > 0) {
        assets = (assets % ((collateral / 10) + 1)) + 1;
    } else {
        assets = (assets % collateral) + 1;
    }
    onBehalf = actor;
    receiver = actor;
    morpho_withdrawCollateral(marketParams, assets, onBehalf, receiver);
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

### morpho_withdrawCollateral(struct MarketParams,uint256,address,address)

- **Kind**: internal
- **Source**: 13407:220:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_withdrawCollateral(struct MarketParams,uint256,address,address)`

```solidity
function morpho_withdrawCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor() {
    morpho.withdrawCollateral(marketParams, assets, onBehalf, receiver);
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

- **Morpho::position(Id,address)**

## State Variable Reads

- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_withdrawCollateral_clamped(struct MarketParams,uint256,address,address) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_withdrawCollateral(struct MarketParams,uint256,address,address) (NodeID: 2)
  │   💬 Args: [marketParams, assets, onBehalf, receiver]
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

@notice Clamped withdraw collateral - only withdraws safe amounts
