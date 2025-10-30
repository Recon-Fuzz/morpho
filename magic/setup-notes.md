# Phase 2 Setup Notes

## Setup Configuration

The Setup contract (`test/recon/Setup.sol`) was NOT modified during Phase 2 implementation. The existing setup was sufficient to support all 26 unit tests for the 25 target functions.

## Current Setup State

### Core Contracts
```solidity
Morpho morpho;              // Main Morpho Blue contract
ERC20Mock loanToken;        // Mock loan token
ERC20Mock collateralToken;  // Mock collateral token
OracleMock oracle;          // Mock oracle for price feeds
IrmMock irm;               // Mock Interest Rate Model
```

### Configuration Constants
- `DECIMALS = 18` (token decimals)
- `ORACLE_PRICE_SCALE = 1e36` (default oracle price, from ConstantsLib)

### Setup Process

The setup() function in Setup.sol performs the following steps:

1. **Add Actors**:
   - Adds 2 additional actors (0x100, 0x200)
   - Total actors: 3 (address(this), 0x100, 0x200)

2. **Deploy Morpho**:
   ```solidity
   morpho = new Morpho(address(this));  // address(this) is owner
   ```

3. **Deploy Mock Tokens**:
   ```solidity
   loanToken = new ERC20Mock();
   collateralToken = new ERC20Mock();
   ```
   - Both tokens added to AssetManager for tracking

4. **Deploy and Configure Oracle**:
   ```solidity
   oracle = new OracleMock();
   oracle.setPrice(ORACLE_PRICE_SCALE);  // 1e36
   ```

5. **Deploy IRM**:
   ```solidity
   irm = new IrmMock();
   ```

6. **Configure Morpho as Owner**:
   ```solidity
   morpho.enableIrm(address(0));      // Zero IRM
   morpho.enableIrm(address(irm));     // Mock IRM
   morpho.enableLltv(0);               // 0% LLTV
   morpho.enableLltv(0.5e18);         // 50% LLTV
   morpho.enableLltv(0.8e18);         // 80% LLTV
   morpho.setFeeRecipient(address(this));
   ```

7. **Create Default Market**:
   ```solidity
   defaultMarketParams = MarketParams({
       loanToken: address(loanToken),
       collateralToken: address(collateralToken),
       oracle: address(oracle),
       irm: address(irm),
       lltv: 0.8e18  // 80% LLTV
   });
   defaultMarketId = defaultMarketParams.id();
   morpho.createMarket(defaultMarketParams);
   ```

8. **Setup Actor Balances and Approvals**:
   For each actor (including address(this)):
   ```solidity
   loanToken.setBalance(actor, type(uint88).max);
   collateralToken.setBalance(actor, type(uint88).max);

   vm.prank(actor);
   loanToken.approve(address(morpho), type(uint256).max);

   vm.prank(actor);
   collateralToken.approve(address(morpho), type(uint256).max);
   ```

## Why No Setup Changes Were Needed

The existing setup was comprehensive enough to support Phase 2 testing of all 25 target functions because:

1. **Market Creation**: Default market (0.8 LLTV) created and ready for use
2. **Multiple LLTVs**: Enabled 0, 0.5e18, and 0.8e18 for testing different market configurations
3. **Mock Contracts**: Flexible mocks (OracleMock, ERC20Mock, IrmMock) that can be manipulated in tests
4. **Admin Access**: Test contract (address(this)) is owner, allowing admin functions to be tested
5. **Actor Management**: ActorManager provides 3 actors for multi-user test scenarios
6. **Asset Management**: AssetManager tracks both loan and collateral tokens
7. **Token Balances**: All actors have type(uint88).max of both tokens (sufficient for all tests)
8. **Approvals**: All actors have max approval for both tokens to Morpho
9. **Oracle Manipulation**: OracleMock.setPrice() allows creating unhealthy positions for liquidation tests
10. **IRM Flexibility**: Both zero IRM and mock IRM enabled for different test scenarios

## Admin Functions Separation

Admin functions were already properly separated in AdminTargets during Phase 1:

### AdminTargets Functions
These functions use `asAdmin` modifier (pranks as address(this)):
- `morpho_enableIrm`
- `morpho_enableLltv`
- `morpho_setFee`
- `morpho_setFeeRecipient`
- `morpho_setOwner`

### MorphoTargets Functions
These functions use `asActor` modifier (pranks as _getActor()):
- `morpho_createMarket`
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

Plus all the clamped and workflow variants.

## Test-Specific Setup Patterns

While the base setup was sufficient, tests build on it with these common patterns:

### Pattern 1: Basic Supply
```solidity
function test_morpho_supply() public {
    uint256 supplyAmount = 1000e18;
    // Tokens already minted and approved in setup
    morpho_supply(defaultMarketParams, supplyAmount, 0, _getActor(), hex"");
}
```

### Pattern 2: Multi-Actor Borrow
```solidity
function test_morpho_borrow() public {
    // Actor 0 provides liquidity
    morpho_supply(defaultMarketParams, 10000e18, 0, _getActor(), hex"");

    // Switch to Actor 1 as borrower
    switchActor(1);

    // Actor 1 supplies collateral and borrows
    morpho_supplyCollateral(defaultMarketParams, 10000e18, _getActor(), hex"");
    morpho_borrow(defaultMarketParams, 1000e18, 0, _getActor(), _getActor());
}
```

### Pattern 3: Create Unhealthy Position for Liquidation
```solidity
function test_morpho_liquidate() public {
    // Setup liquidity and high-LTV borrow
    morpho_supply(defaultMarketParams, 10000e18, 0, _getActor(), hex"");
    switchActor(1);
    morpho_supplyCollateral(defaultMarketParams, 10000e18, borrower, hex"");
    morpho_borrow(defaultMarketParams, 7000e18, 0, borrower, borrower);

    // Make position unhealthy by dropping oracle price
    oracle.setPrice(ORACLE_PRICE_SCALE / 2);  // 50% price drop

    // Switch to liquidator and liquidate
    switchActor(0);
    morpho_liquidate(defaultMarketParams, borrower, 0, 1e18, hex"");
}
```

## Modifiers

The Setup contract defines two modifiers for access control:

### asAdmin
```solidity
modifier asAdmin {
    vm.prank(address(this));
    _;
}
```
- Used for owner-only functions in AdminTargets
- Pranks as the test contract (owner of Morpho)

### asActor
```solidity
modifier asActor {
    vm.prank(address(_getActor()));
    _;
}
```
- Used for user-callable functions in MorphoTargets
- Pranks as the currently selected actor from ActorManager
- Default actor is address(this), can be changed with `switchActor(uint)`

## Key Setup Features

1. **Flexibility**: Mock contracts allow per-test manipulation (oracle price, token balances, etc.)
2. **Pre-Approved**: All actors have max approval for both tokens, eliminating approval setup in tests
3. **Pre-Funded**: All actors start with type(uint88).max of both tokens
4. **Admin Access**: Test contract (address(this)) is owner, enabling admin function testing
5. **Actor Management**: ActorManager provides multi-user scenario support
6. **Asset Management**: AssetManager tracks loan and collateral tokens
7. **Ready Market**: Default market already created and usable

## Setup Strengths for Phase 2 Testing

1. **No Setup Modifications Required**: All 26 tests passed without any changes to Setup.sol
2. **Comprehensive Coverage**: Supports all 25 target functions from testing_priority.md
3. **Oracle Flexibility**: Easy to create unhealthy positions for liquidation testing
4. **Multi-Actor Support**: Enables testing of interactions between lenders, borrowers, and liquidators
5. **Flash Loan Support**: Test contract implements IMorphoFlashLoanCallback for flash loan tests

## Important Notes

- **Setup Invocation**: The Setup.setup() function is called once in CryticToFoundry.setUp()
- **Do Not Modify**: Tests should NOT modify the setup() function in Setup.sol
- **Test State**: Tests build their own state using target functions (morpho_supply, etc.)
- **Default Market**: Always available via `defaultMarketParams` and `defaultMarketId`
- **Oracle Manipulation**: Use `oracle.setPrice()` to create unhealthy positions for liquidation
- **Actor Switching**: Use `switchActor(uint)` to test different user scenarios

## Comparison to Requirements

The setup successfully provides all requirements from the Phase 2 workflow:

- Actors: 3 actors (requirement: 2+)
- Tokens: Both loan and collateral tokens with balances and approvals
- Oracle: Mock oracle with manipulable price
- IRM: Mock IRM deployed and enabled
- Markets: Default market created with 0.8 LLTV
- Admin Access: Test contract is owner for admin functions
- Multiple LLTVs: 0, 0.5e18, 0.8e18 enabled for market creation tests

## Conclusion

The Setup.sol configuration from Phase 1 proved to be comprehensive and required zero modifications for Phase 2. All 26 unit tests for the 25 target functions passed, demonstrating that the setup provides:

1. Proper actor management for multi-user scenarios
2. Sufficient token balances and approvals
3. Flexible mock contracts for test manipulation
4. Correct admin access control
5. A ready-to-use default market

No setup changes are documented in setup-notes.md because none were needed.
