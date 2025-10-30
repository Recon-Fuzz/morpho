# Function: test_morpho_supplyCollateral()

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `test_morpho_supplyCollateral()`
- **Visibility**: public
- **Source Range**: 4587:430:60

## Implementation

```solidity
function test_morpho_supplyCollateral() public {
    uint256 collateralAmount = 1000e18;
    morpho_supplyCollateral(defaultMarketParams, collateralAmount, _getActor(), hex"");
    (, , uint128 collateral) = morpho.position(defaultMarketId, _getActor());
    require(collateral > 0, "Collateral should be greater than 0");
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

## External Calls

- **Morpho::position(Id,address)**

## State Variable Reads

- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: CryticToFoundry.test_morpho_supplyCollateral() (NodeID: 0)
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
  └─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 5)
      💬 Args: [no args]
      👁️  Def: internal
```
