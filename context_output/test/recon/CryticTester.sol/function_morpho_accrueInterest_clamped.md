# Function: morpho_accrueInterest_clamped()

**Contract**: [test/recon/CryticTester.sol/contract_CryticTester.md]

## Metadata

- **Contract**: CryticTester
- **Signature**: `morpho_accrueInterest_clamped()`
- **Visibility**: public
- **Source Range**: 10008:107:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped accrue interest - always uses default market
function morpho_accrueInterest_clamped() public {
    morpho_accrueInterest(defaultMarketParams);
}
```

## Related Implementations

### morpho_accrueInterest(struct MarketParams)

- **Kind**: internal
- **Source**: 11249:132:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_accrueInterest(struct MarketParams)`

```solidity
/// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///
function morpho_accrueInterest(MarketParams memory marketParams) public asActor() {
    morpho.accrueInterest(marketParams);
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

## State Variable Reads

- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_accrueInterest_clamped() (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  └─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_accrueInterest(struct MarketParams) (NodeID: 1)
      💬 Args: [defaultMarketParams]
      👁️  Def: public
    └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 2)
        💬 Args: [no args]
      └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 3)
          💬 Args: [no args]
          👁️  Def: internal
```

## Documentation

### Function Documentation

@notice Clamped accrue interest - always uses default market
