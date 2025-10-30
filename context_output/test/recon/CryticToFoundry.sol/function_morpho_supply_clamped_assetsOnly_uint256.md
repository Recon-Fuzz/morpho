# Function: morpho_supply_clamped_assetsOnly(uint256)

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `morpho_supply_clamped_assetsOnly(uint256)`
- **Visibility**: public
- **Source Range**: 2058:206:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Supply pure assets (no shares) with clamped market
function morpho_supply_clamped_assetsOnly(uint256 assets) public asActor() {
    assets = (assets % MAX_SUPPLY_AMOUNT) + 1;
    morpho_supply(defaultMarketParams, assets, 0, _getActor(), hex"");
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

## State Variable Reads

- **MAX_SUPPLY_AMOUNT** (`uint256`)
- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_supply_clamped_assetsOnly(uint256) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_supply(struct MarketParams,uint256,uint256,address,bytes) (NodeID: 1)
  │   💬 Args: [defaultMarketParams, assets, 0, _getActor(), hex""]
  │   👁️  Def: public
  │ ├─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 4)
  │ │   💬 Args: [no args]
  │ │   👁️  Def: internal
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 2)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 3)
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

@notice Supply pure assets (no shares) with clamped market
