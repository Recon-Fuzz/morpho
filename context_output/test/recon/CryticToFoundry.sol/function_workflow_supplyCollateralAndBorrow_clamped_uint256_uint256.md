# Function: workflow_supplyCollateralAndBorrow_clamped(uint256,uint256)

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `workflow_supplyCollateralAndBorrow_clamped(uint256,uint256)`
- **Visibility**: public
- **Source Range**: 10233:669:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Complete supply-borrow workflow with clamped values
function workflow_supplyCollateralAndBorrow_clamped(uint256 collateralAmt, uint256 borrowAmt) public asActor() {
    address actor = _getActor();
    collateralAmt = (collateralAmt % MAX_COLLATERAL_AMOUNT) + 1;
    morpho.supplyCollateral(defaultMarketParams, collateralAmt, actor, hex"");
    uint256 maxBorrow = ((collateralAmt * 8) / 10) / 2;
    if (maxBorrow == 0) return;
    borrowAmt = (borrowAmt % maxBorrow) + 1;
    morpho.borrow(defaultMarketParams, borrowAmt, 0, actor, actor);
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

- **Morpho::supplyCollateral(struct MarketParams,uint256,address,bytes)**
- **Morpho::borrow(struct MarketParams,uint256,uint256,address,address)**

## State Variable Reads

- **MAX_COLLATERAL_AMOUNT** (`uint256`)
- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.workflow_supplyCollateralAndBorrow_clamped(uint256,uint256) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 1)
  │   💬 Args: [no args]
  │   👁️  Def: internal
  └─ [1] 🔒 MODIFIER: Setup.asActor() (NodeID: 2)
      💬 Args: [no args]
    └─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 3)
        💬 Args: [no args]
        👁️  Def: internal
```

## Documentation

### Function Documentation

@notice Complete supply-borrow workflow with clamped values
