# Function: morpho_repay_clamped(struct MarketParams,uint256,uint256,address,bytes)

**Contract**: [test/recon/CryticTester.sol/contract_CryticTester.md]

## Metadata

- **Contract**: CryticTester
- **Signature**: `morpho_repay_clamped(struct MarketParams,uint256,uint256,address,bytes)`
- **Visibility**: public
- **Source Range**: 6877:650:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped repay function - only repays existing debt
function morpho_repay_clamped(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor() {
    marketParams = defaultMarketParams;
    address actor = _getActor();
    (, uint256 borrowShares, ) = morpho.position(defaultMarketId, actor);
    if (borrowShares == 0) return;
    shares = (shares % borrowShares) + 1;
    assets = 0;
    onBehalf = actor;
    morpho_repay(marketParams, assets, shares, onBehalf, data);
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

### morpho_repay(struct MarketParams,uint256,uint256,address,bytes)

- **Kind**: internal
- **Source**: 12151:215:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_repay(struct MarketParams,uint256,uint256,address,bytes)`

```solidity
function morpho_repay(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor() {
    morpho.repay(marketParams, assets, shares, onBehalf, data);
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
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_repay_clamped(struct MarketParams,uint256,uint256,address,bytes) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_repay(struct MarketParams,uint256,uint256,address,bytes) (NodeID: 2)
  │   💬 Args: [marketParams, assets, shares, onBehalf, data]
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

@notice Clamped repay function - only repays existing debt
