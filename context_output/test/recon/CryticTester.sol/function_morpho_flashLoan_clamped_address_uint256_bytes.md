# Function: morpho_flashLoan_clamped(address,uint256,bytes)

**Contract**: [test/recon/CryticTester.sol/contract_CryticTester.md]

## Metadata

- **Contract**: CryticTester
- **Signature**: `morpho_flashLoan_clamped(address,uint256,bytes)`
- **Visibility**: public
- **Source Range**: 8794:493:67
- **Inherited From**: MorphoTargets

## Implementation

```solidity
/// @notice Clamped flashloan - only borrows available liquidity
function morpho_flashLoan_clamped(address token, uint256 assets, bytes memory data) public asActor() {
    token = address(loanToken);
    uint256 available = loanToken.balanceOf(address(morpho));
    if (available == 0) return;
    assets = (assets % available) + 1;
    morpho_flashLoan(token, assets, data);
}
```

## Related Implementations

### morpho_flashLoan(address,uint256,bytes)

- **Kind**: internal
- **Source**: 11747:145:67
- **Link**: `test/recon/targets/MorphoTargets.sol:MorphoTargets:morpho_flashLoan(address,uint256,bytes)`

```solidity
function morpho_flashLoan(address token, uint256 assets, bytes memory data) public asActor() {
    morpho.flashLoan(token, assets, data);
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

## External Calls

- **ERC20Mock::balanceOf(address)**

## State Variable Reads

- **_actor** (`address`)

## Call Tree

```
┌─ [0] ⚙️ FUNCTION: MorphoTargets.morpho_flashLoan_clamped(address,uint256,bytes) (NodeID: 0)
    💬 Args: [no args]
    👁️  Def: public
  ├─ [1] ⚙️ FUNCTION: MorphoTargets.morpho_flashLoan(address,uint256,bytes) (NodeID: 1)
  │   💬 Args: [token, assets, data]
  │   👁️  Def: public
  │ └─ [2] 🔒 MODIFIER: Setup.asActor() (NodeID: 2)
  │     💬 Args: [no args]
  │   └─ [3] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 3)
  │       💬 Args: [no args]
  │       👁️  Def: internal
  └─ [1] 🔒 MODIFIER: Setup.asActor() (NodeID: 4)
      💬 Args: [no args]
    └─ [2] ⚙️ FUNCTION: ActorManager._getActor() (NodeID: 5)
        💬 Args: [no args]
        👁️  Def: internal
```

## Documentation

### Function Documentation

@notice Clamped flashloan - only borrows available liquidity
