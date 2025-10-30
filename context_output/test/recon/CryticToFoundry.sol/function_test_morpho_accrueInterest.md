# Function: test_morpho_accrueInterest()

**Contract**: [test/recon/CryticToFoundry.sol/contract_CryticToFoundry.md]

## Metadata

- **Contract**: CryticToFoundry
- **Signature**: `test_morpho_accrueInterest()`
- **Visibility**: public
- **Source Range**: 3744:172:60

## Implementation

```solidity
function test_morpho_accrueInterest() public {
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
┌─ [0] ⚙️ FUNCTION: CryticToFoundry.test_morpho_accrueInterest() (NodeID: 0)
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
