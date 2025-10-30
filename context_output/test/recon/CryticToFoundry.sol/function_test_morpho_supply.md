# Function: test_morpho_supply()

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `test_morpho_supply()`
- **Visibility**: public
- **Source Range**: 3996:501:60

## Implementation

```solidity
function test_morpho_supply() public {
    uint256 supplyAmount = 1000e18;
    morpho_supply(defaultMarketParams, supplyAmount, 0, _getActor(), hex"");
    (uint256 supplyShares, , ) = morpho.position(defaultMarketId, _getActor());
    require(supplyShares > 0, "Supply shares should be greater than 0");
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

## External Calls

- **Morpho::position(Id,address)**

## State Variable Reads

- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: CryticToFoundry.test_morpho_supply() (NodeID: 0)
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
  └─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 5)
      💬 Args: [no args]
      👁️  Def: internal
```
