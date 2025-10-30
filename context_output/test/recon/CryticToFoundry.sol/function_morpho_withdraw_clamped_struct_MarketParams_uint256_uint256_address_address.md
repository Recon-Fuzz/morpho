# Function: morpho_withdraw_clamped(struct MarketParams,uint256,uint256,address,address)

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `morpho_withdraw_clamped(struct MarketParams,uint256,uint256,address,address)`
- **Visibility**: public
- **Source Range**: 2390:727:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped withdraw function - only withdraws what was supplied
function morpho_withdraw_clamped(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor() {
    marketParams = defaultMarketParams;
    address actor = _getActor();
    (uint256 supplyShares, , ) = morpho.position(defaultMarketId, actor);
    if (supplyShares == 0) return;
    shares = (shares % supplyShares) + 1;
    assets = 0;
    onBehalf = actor;
    receiver = actor;
    morpho_withdraw(marketParams, assets, shares, onBehalf, receiver);
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

### morpho_withdraw(struct MarketParams,uint256,uint256,address,address)

- **Kind**: internal
- **Source**: 13177:224:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_withdraw(struct MarketParams,uint256,uint256,address,address)`

```solidity
function morpho_withdraw(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor() {
    morpho.withdraw(marketParams, assets, shares, onBehalf, receiver);
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
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_withdraw_clamped(struct MarketParams,uint256,uint256,address,address) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_withdraw(struct MarketParams,uint256,uint256,address,address) (NodeID: 2)
  │   💬 Args: [marketParams, assets, shares, onBehalf, receiver]
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

@notice Clamped withdraw function - only withdraws what was supplied
