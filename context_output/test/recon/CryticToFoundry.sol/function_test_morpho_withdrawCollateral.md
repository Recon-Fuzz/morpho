# Function: test_morpho_withdrawCollateral()

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `test_morpho_withdrawCollateral()`
- **Visibility**: public
- **Source Range**: 5711:600:60

## Implementation

```solidity
function test_morpho_withdrawCollateral() public {
    uint256 collateralAmount = 1000e18;
    uint256 withdrawAmount = 500e18;
    morpho_supplyCollateral(defaultMarketParams, collateralAmount, _getActor(), hex"");
    morpho_withdrawCollateral(defaultMarketParams, withdrawAmount, _getActor(), _getActor());
    (, , uint128 collateral) = morpho.position(defaultMarketId, _getActor());
    require(collateral > 0, "Should still have some collateral");
}
```

## Related Implementations

### morpho_supplyCollateral(struct MarketParams,uint256,address,bytes)

- **Kind**: internal
- **Source**: 12958:213:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_supplyCollateral(struct MarketParams,uint256,address,bytes)`

```solidity
function morpho_supplyCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data) public asActor() {
    morpho.supplyCollateral(marketParams, assets, onBehalf, data);
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

### morpho_withdrawCollateral(struct MarketParams,uint256,address,address)

- **Kind**: internal
- **Source**: 13407:220:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_withdrawCollateral(struct MarketParams,uint256,address,address)`

```solidity
function morpho_withdrawCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor() {
    morpho.withdrawCollateral(marketParams, assets, onBehalf, receiver);
}
```

## External Calls

- **Morpho::position(Id,address)**

## State Variable Reads

- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: CryticToFoundry.test_morpho_withdrawCollateral() (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_supplyCollateral(struct MarketParams,uint256,address,bytes) (NodeID: 1)
  │   💬 Args: [defaultMarketParams, collateralAmount, _getActor(), hex""]
  │   👁️  Def: public
  │ ├─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 4)
  │ │   💬 Args: [no args]
  │ │   👁️  Def: internal
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 2)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 3)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_withdrawCollateral(struct MarketParams,uint256,address,address) (NodeID: 5)
  │   💬 Args: [defaultMarketParams, withdrawAmount, _getActor(), _getActor()]
  │   👁️  Def: public
  │ ├─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 8)
  │ │   💬 Args: [no args]
  │ │   👁️  Def: internal
  │ ├─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 9)
  │ │   💬 Args: [no args]
  │ │   👁️  Def: internal
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 6)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 7)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  └─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 10)
      💬 Args: [no args]
      👁️  Def: internal
```
