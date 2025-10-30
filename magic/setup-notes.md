# Phase 2 Setup Notes

## Setup Configuration

The Setup contract (`test/recon/Setup.sol`) was NOT modified during Phase 2 implementation. The existing Phase 1 setup was sufficient to support all test scenarios.

## Current Setup State

### Core Contracts
```solidity
Morpho morpho;           // Main Morpho Blue contract
ERC20Mock loanToken;     // Mock loan token (e.g., USDC)
ERC20Mock collateralToken; // Mock collateral token (e.g., wETH)
OracleMock oracle;       // Mock oracle for price feeds
IrmMock irm;            // Mock Interest Rate Model
```

### Configuration Constants
- `DEFAULT_LLTV = 0.8 ether` (80% loan-to-value ratio)
- `ORACLE_PRICE_SCALE = 1e36` (default oracle price scale)

### Setup Process

1. **Owner Setup**: `owner = address(this)` (test contract is owner)
2. **Fee Recipient**: `feeRecipient = address(0x1234)`
3. **Morpho Deployment**: `morpho = new Morpho(owner)`
4. **Mock Deployments**: Deploy ERC20Mock, OracleMock, IrmMock
5. **Oracle Configuration**: Set initial price to `ORACLE_PRICE_SCALE`
6. **IRM Enablement**: Enable address(0) and deployed IRM
7. **LLTV Enablement**: Enable 0 and DEFAULT_LLTV (0.8 ether)
8. **Fee Recipient**: Set to `feeRecipient`
9. **Market Creation**: Create default market with loanToken, collateralToken, oracle, irm, and DEFAULT_LLTV

### Market Parameters
The default market uses:
```solidity
marketParams = MarketParams({
    loanToken: address(loanToken),
    collateralToken: address(collateralToken),
    oracle: address(oracle),
    irm: address(irm),
    lltv: DEFAULT_LLTV
});
```

## Why No Setup Changes Were Needed

The Phase 1 setup was comprehensive enough to support Phase 2 testing because:

1. **Market Creation**: Already creates a default market that all tests can use
2. **Mock Contracts**: Provides flexible mocks (OracleMock, ERC20Mock) that can be manipulated in tests
3. **Admin Access**: Test contract is the owner, allowing admin functions to be tested
4. **Token Flexibility**: ERC20Mock.setBalance() allows any test to mint tokens on-demand
5. **Oracle Manipulation**: OracleMock.setPrice() allows tests to create unhealthy positions
6. **IRM/LLTV Enablement**: Already enables the necessary parameters for borrowing

## Test-Specific Setup Patterns

While the base setup was sufficient, tests implement their own setup patterns:

### Pattern 1: Supply Liquidity
```solidity
loanToken.setBalance(address(this), amount);
loanToken.approve(address(morpho), type(uint256).max);
morpho.supply(marketParams, amount, 0, address(this), "");
```

### Pattern 2: Supply Collateral and Borrow
```solidity
collateralToken.setBalance(borrower, collateralAmount);
vm.startPrank(borrower);
collateralToken.approve(address(morpho), type(uint256).max);
morpho.supplyCollateral(marketParams, collateralAmount, borrower, "");
morpho.borrow(marketParams, borrowAmount, 0, borrower, borrower);
vm.stopPrank();
```

### Pattern 3: Create Unhealthy Position
```solidity
// First: Normal borrow setup (Pattern 2)
// Then: Drop oracle price
oracle.setPrice(ORACLE_PRICE_SCALE / 10); // 90% price drop
```

### Pattern 4: EIP-712 Signature Authorization
```solidity
uint256 privateKey = 0x1234;
address authorizer = vm.addr(privateKey);

Authorization memory authorization = Authorization({
    authorizer: authorizer,
    authorized: authorized,
    isAuthorized: true,
    nonce: 0,
    deadline: block.timestamp + 1 days
});

bytes32 digest = SigUtils.getTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);
(sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);
```

## Admin Functions Separation

During Phase 2, admin functions were moved from MorphoTargets to AdminTargets:

### Functions Moved to AdminTargets
These functions now use `asAdmin` modifier (pranks as address(this)):
- `morpho_enableIrm`
- `morpho_enableLltv`
- `morpho_setFee`
- `morpho_setFeeRecipient`
- `morpho_setOwner`
- `morpho_createMarket`

### Functions Remaining in MorphoTargets
These functions use `asActor` modifier (pranks as _getActor()):
- `morpho_accrueInterest`
- `morpho_borrow`
- `morpho_flashLoan`
- `morpho_liquidate`
- `morpho_repay`
- `morpho_setAuthorization`
- `morpho_setAuthorizationWithSig`
- `morpho_supply`
- `morpho_supplyCollateral`
- `morpho_withdraw`
- `morpho_withdrawCollateral`

## Modifiers

### asAdmin
```solidity
modifier asAdmin {
    vm.prank(address(this));
    _;
}
```
Used for owner-only functions.

### asActor
```solidity
modifier asActor {
    vm.prank(address(_getActor()));
    _;
}
```
Used for user-callable functions, pranks as the currently selected actor from ActorManager.

## Key Setup Features

1. **Flexibility**: Mock contracts allow per-test customization
2. **Isolation**: Each test sets up its own state (balances, positions)
3. **Admin Access**: Test contract has owner privileges for admin functions
4. **Actor Management**: Uses ActorManager for multi-user scenarios
5. **Asset Management**: Uses AssetManager for multi-asset scenarios (if needed)

## Future Setup Considerations

If future testing requires additional setup:

1. **Multiple Markets**: Create additional markets with different parameters
2. **Fee Testing**: Set non-zero fees on markets for fee-related tests
3. **Multiple Assets**: Deploy additional token pairs for cross-market tests
4. **Custom IRM**: Deploy IRMs with specific rate models
5. **Custom Oracles**: Deploy oracles with specific price behaviors

## Important Notes

- The Setup.setup() function is called once in CryticToFoundry.setUp()
- Tests should NOT modify the setup() function
- Tests should set up their own state using token minting and morpho interactions
- The default market is always available for use in tests
- Oracle price can be freely manipulated for testing unhealthy positions
