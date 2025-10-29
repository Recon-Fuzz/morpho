// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {MarketParams, Id, Position, Market, Authorization, Signature} from "src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";
import {MathLib, WAD} from "src/libraries/MathLib.sol";
import {SharesMathLib} from "src/libraries/SharesMathLib.sol";
import {IERC20} from "src/interfaces/IERC20.sol";
import {ERC20Mock} from "src/mocks/ERC20Mock.sol";
import {EventsLib} from "src/libraries/EventsLib.sol";
import {Morpho} from "src/Morpho.sol";
import "src/libraries/ConstantsLib.sol";
import {SigUtils} from "../forge/helpers/SigUtils.sol";

// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    using MarketParamsLib for MarketParams;
    using MathLib for uint256;
    using SharesMathLib for uint256;

    function setUp() public {
        setup();

        targetContract(address(this));
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_setAuthorization
    // =========================================================================

    /// @notice Test that authorization is correctly set
    function test_setAuthorization_setsCorrectState() public {
        address actor = _getActor();
        address authorized = address(0x9999);

        vm.startPrank(actor);

        // Initially should not be authorized
        assertFalse(morpho.isAuthorized(actor, authorized));

        // Set authorization to true
        morpho.setAuthorization(authorized, true);
        assertTrue(morpho.isAuthorized(actor, authorized));

        // Set authorization to false
        morpho.setAuthorization(authorized, false);
        assertFalse(morpho.isAuthorized(actor, authorized));

        vm.stopPrank();
    }

    /// @notice Test that authorization changes emit events
    function test_setAuthorization_emitsEvent() public {
        address actor = _getActor();
        address authorized = address(0x9999);

        vm.startPrank(actor);

        vm.expectEmit(true, true, true, true);
        emit EventsLib.SetAuthorization(actor, actor, authorized, true);
        morpho.setAuthorization(authorized, true);

        vm.stopPrank();
    }

    /// @notice Test that setting the same authorization twice reverts
    function test_setAuthorization_revertsOnDuplicate() public {
        address actor = _getActor();
        address authorized = address(0x9999);

        vm.startPrank(actor);

        morpho.setAuthorization(authorized, true);

        // Setting the same value should revert
        vm.expectRevert();
        morpho.setAuthorization(authorized, true);

        vm.stopPrank();
    }

    /// @notice Test that authorization doesn't affect other users
    function test_setAuthorization_doesNotAffectOtherUsers() public {
        address actor1 = address(0x1111);
        address actor2 = address(0x2222);
        address authorized = address(0x9999);

        vm.prank(actor1);
        morpho.setAuthorization(authorized, true);

        // actor2 should not be affected
        assertFalse(morpho.isAuthorized(actor2, authorized));
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_flashLoan
    // =========================================================================

    /// @notice Test that flash loan with zero amount reverts
    function test_flashLoan_revertsOnZeroAmount() public {
        address actor = _getActor();

        vm.prank(actor);
        vm.expectRevert();
        morpho.flashLoan(address(loanToken), 0, "");
    }

    /// @notice Test that flash loan preserves contract balance
    function test_flashLoan_preservesBalance() public {
        // Set up some liquidity
        uint256 supplyAmount = 1000e18;
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        uint256 balanceBefore = loanToken.balanceOf(address(morpho));

        // Create a flash loan borrower that returns the tokens
        FlashLoanBorrower borrower = new FlashLoanBorrower(address(morpho), address(loanToken));
        uint256 flashAmount = 500e18;
        loanToken.setBalance(address(borrower), flashAmount); // Give borrower tokens to repay

        borrower.executeFlashLoan(address(loanToken), flashAmount);

        uint256 balanceAfter = loanToken.balanceOf(address(morpho));

        // Balance should be preserved (no fee on flash loans)
        assertEq(balanceBefore, balanceAfter);
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_accrueInterest
    // =========================================================================

    /// @notice Test that accruing interest on non-existent market reverts
    function test_accrueInterest_revertsOnNonExistentMarket() public {
        MarketParams memory fakeMarket = MarketParams({
            loanToken: address(0x1234),
            collateralToken: address(0x5678),
            oracle: address(0x9abc),
            irm: address(0xdef0),
            lltv: 0.5 ether
        });

        vm.expectRevert();
        morpho.accrueInterest(fakeMarket);
    }

    /// @notice Test that accruing interest updates lastUpdate timestamp
    function test_accrueInterest_updatesTimestamp() public {
        (,,,,uint128 lastUpdateBefore,) = morpho.market(marketId);

        // Move time forward
        vm.warp(block.timestamp + 100);

        morpho.accrueInterest(marketParams);

        (,,,,uint128 lastUpdateAfter,) = morpho.market(marketId);

        assertGt(lastUpdateAfter, lastUpdateBefore);
    }

    /// @notice Test that accruing interest with no borrows doesn't change state
    function test_accrueInterest_noChangeWithoutBorrows() public {
        (uint128 totalSupplyAssetsBefore, uint128 totalSupplySharesBefore, uint128 totalBorrowAssetsBefore, uint128 totalBorrowSharesBefore,,) = morpho.market(marketId);

        vm.warp(block.timestamp + 100);
        morpho.accrueInterest(marketParams);

        (uint128 totalSupplyAssetsAfter, uint128 totalSupplySharesAfter, uint128 totalBorrowAssetsAfter, uint128 totalBorrowSharesAfter,,) = morpho.market(marketId);

        // With no borrows, supply and borrow amounts should be unchanged
        assertEq(totalSupplyAssetsBefore, totalSupplyAssetsAfter);
        assertEq(totalSupplySharesBefore, totalSupplySharesAfter);
        assertEq(totalBorrowAssetsBefore, totalBorrowAssetsAfter);
        assertEq(totalBorrowSharesBefore, totalBorrowSharesAfter);
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_supply
    // =========================================================================

    /// @notice Test that supply increases user's supply shares
    function test_supply_increasesUserShares() public {
        address actor = _getActor();
        uint256 supplyAmount = 1000e18;

        loanToken.setBalance(actor, supplyAmount);

        vm.startPrank(actor);
        loanToken.approve(address(morpho), type(uint256).max);

        (uint256 supplySharesBefore,,) = morpho.position(marketId, actor);

        morpho.supply(marketParams, supplyAmount, 0, actor, "");

        (uint256 supplySharesAfter,,) = morpho.position(marketId, actor);

        assertGt(supplySharesAfter, supplySharesBefore);
        vm.stopPrank();
    }

    /// @notice Test that supply increases total supply
    function test_supply_increasesTotalSupply() public {
        address actor = _getActor();
        uint256 supplyAmount = 1000e18;

        loanToken.setBalance(actor, supplyAmount);

        (uint128 totalSupplyAssetsBefore, uint128 totalSupplySharesBefore,,,,) = morpho.market(marketId);

        vm.startPrank(actor);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, actor, "");
        vm.stopPrank();

        (uint128 totalSupplyAssetsAfter, uint128 totalSupplySharesAfter,,,,) = morpho.market(marketId);

        assertGt(totalSupplyAssetsAfter, totalSupplyAssetsBefore);
        assertGt(totalSupplySharesAfter, totalSupplySharesBefore);
    }

    /// @notice Test that supply with both assets and shares reverts
    function test_supply_revertsWithBothParams() public {
        address actor = _getActor();
        uint256 supplyAmount = 1000e18;

        loanToken.setBalance(actor, supplyAmount);

        vm.startPrank(actor);
        loanToken.approve(address(morpho), type(uint256).max);

        vm.expectRevert();
        morpho.supply(marketParams, supplyAmount, supplyAmount, actor, "");

        vm.stopPrank();
    }

    /// @notice Test that supply to zero address reverts
    function test_supply_revertsOnZeroAddress() public {
        address actor = _getActor();
        uint256 supplyAmount = 1000e18;

        loanToken.setBalance(actor, supplyAmount);

        vm.startPrank(actor);
        loanToken.approve(address(morpho), type(uint256).max);

        vm.expectRevert();
        morpho.supply(marketParams, supplyAmount, 0, address(0), "");

        vm.stopPrank();
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_supplyCollateral
    // =========================================================================

    /// @notice Test that supply collateral increases user's collateral
    function test_supplyCollateral_increasesUserCollateral() public {
        address actor = _getActor();
        uint256 collateralAmount = 1000e18;

        collateralToken.setBalance(actor, collateralAmount);

        vm.startPrank(actor);
        collateralToken.approve(address(morpho), type(uint256).max);

        (,, uint128 collateralBefore) = morpho.position(marketId, actor);

        morpho.supplyCollateral(marketParams, collateralAmount, actor, "");

        (,, uint128 collateralAfter) = morpho.position(marketId, actor);

        assertEq(collateralAfter, collateralBefore + collateralAmount);
        vm.stopPrank();
    }

    /// @notice Test that supply collateral with zero amount reverts
    function test_supplyCollateral_revertsOnZeroAmount() public {
        address actor = _getActor();

        vm.prank(actor);
        vm.expectRevert();
        morpho.supplyCollateral(marketParams, 0, actor, "");
    }

    /// @notice Test that supply collateral to zero address reverts
    function test_supplyCollateral_revertsOnZeroAddress() public {
        address actor = _getActor();
        uint256 collateralAmount = 1000e18;

        collateralToken.setBalance(actor, collateralAmount);

        vm.startPrank(actor);
        collateralToken.approve(address(morpho), type(uint256).max);

        vm.expectRevert();
        morpho.supplyCollateral(marketParams, collateralAmount, address(0), "");

        vm.stopPrank();
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_withdraw
    // =========================================================================

    /// @notice Test that withdraw decreases user's supply shares
    function test_withdraw_decreasesUserShares() public {
        address actor = _getActor();
        uint256 supplyAmount = 1000e18;
        uint256 withdrawAmount = 500e18;

        // First supply
        loanToken.setBalance(actor, supplyAmount);
        vm.startPrank(actor);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, actor, "");

        (uint256 supplySharesBefore,,) = morpho.position(marketId, actor);

        // Then withdraw
        morpho.withdraw(marketParams, withdrawAmount, 0, actor, actor);

        (uint256 supplySharesAfter,,) = morpho.position(marketId, actor);

        assertLt(supplySharesAfter, supplySharesBefore);
        vm.stopPrank();
    }

    /// @notice Test that withdraw without authorization reverts
    function test_withdraw_revertsWithoutAuthorization() public {
        address supplier = address(0x1111);
        address unauthorized = address(0x2222);
        uint256 supplyAmount = 1000e18;

        // Supplier supplies
        loanToken.setBalance(supplier, supplyAmount);
        vm.startPrank(supplier);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, supplier, "");
        vm.stopPrank();

        // Unauthorized tries to withdraw
        vm.prank(unauthorized);
        vm.expectRevert();
        morpho.withdraw(marketParams, 100e18, 0, supplier, unauthorized);
    }

    /// @notice Test that withdraw transfers tokens to receiver
    function test_withdraw_transfersTokens() public {
        address actor = _getActor();
        address receiver = address(0x9999);
        uint256 supplyAmount = 1000e18;
        uint256 withdrawAmount = 500e18;

        // First supply
        loanToken.setBalance(actor, supplyAmount);
        vm.startPrank(actor);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, actor, "");

        uint256 receiverBalanceBefore = loanToken.balanceOf(receiver);

        // Then withdraw
        morpho.withdraw(marketParams, withdrawAmount, 0, actor, receiver);

        uint256 receiverBalanceAfter = loanToken.balanceOf(receiver);

        assertEq(receiverBalanceAfter, receiverBalanceBefore + withdrawAmount);
        vm.stopPrank();
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_borrow
    // =========================================================================

    /// @notice Test that borrow increases user's borrow shares
    function test_borrow_increasesUserBorrowShares() public {
        address actor = _getActor();
        uint256 collateralAmount = 10000e18;
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 1000e18;

        // Setup: supply liquidity and collateral
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        collateralToken.setBalance(actor, collateralAmount);
        vm.startPrank(actor);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, actor, "");

        (, uint128 borrowSharesBefore,) = morpho.position(marketId, actor);

        // Borrow
        morpho.borrow(marketParams, borrowAmount, 0, actor, actor);

        (, uint128 borrowSharesAfter,) = morpho.position(marketId, actor);

        assertGt(borrowSharesAfter, borrowSharesBefore);
        vm.stopPrank();
    }

    /// @notice Test that borrow without collateral reverts
    function test_borrow_revertsWithoutCollateral() public {
        address actor = _getActor();
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 1000e18;

        // Setup: supply liquidity
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        // Try to borrow without collateral
        vm.prank(actor);
        vm.expectRevert();
        morpho.borrow(marketParams, borrowAmount, 0, actor, actor);
    }

    /// @notice Test that borrow without authorization reverts
    function test_borrow_revertsWithoutAuthorization() public {
        address borrower = address(0x1111);
        address unauthorized = address(0x2222);
        uint256 collateralAmount = 10000e18;
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 1000e18;

        // Setup: supply liquidity
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        // Setup: borrower supplies collateral
        collateralToken.setBalance(borrower, collateralAmount);
        vm.startPrank(borrower);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, borrower, "");
        vm.stopPrank();

        // Unauthorized tries to borrow
        vm.prank(unauthorized);
        vm.expectRevert();
        morpho.borrow(marketParams, borrowAmount, 0, borrower, unauthorized);
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_repay
    // =========================================================================

    /// @notice Test that repay decreases user's borrow shares
    function test_repay_decreasesUserBorrowShares() public {
        address actor = _getActor();
        uint256 collateralAmount = 10000e18;
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 1000e18;
        uint256 repayAmount = 500e18;

        // Setup: supply liquidity and collateral, then borrow
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        collateralToken.setBalance(actor, collateralAmount);
        vm.startPrank(actor);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, actor, "");
        morpho.borrow(marketParams, borrowAmount, 0, actor, actor);

        (, uint128 borrowSharesBefore,) = morpho.position(marketId, actor);

        // Repay
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.repay(marketParams, repayAmount, 0, actor, "");

        (, uint128 borrowSharesAfter,) = morpho.position(marketId, actor);

        assertLt(borrowSharesAfter, borrowSharesBefore);
        vm.stopPrank();
    }

    /// @notice Test that anyone can repay on behalf of borrower
    function test_repay_anyoneCanRepay() public {
        address borrower = address(0x1111);
        address repayer = address(0x2222);
        uint256 collateralAmount = 10000e18;
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 1000e18;
        uint256 repayAmount = 500e18;

        // Setup: supply liquidity
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        // Setup: borrower borrows
        collateralToken.setBalance(borrower, collateralAmount);
        vm.startPrank(borrower);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, borrower, "");
        morpho.borrow(marketParams, borrowAmount, 0, borrower, borrower);
        vm.stopPrank();

        (, uint128 borrowSharesBefore,) = morpho.position(marketId, borrower);

        // Repayer repays on behalf of borrower
        loanToken.setBalance(repayer, repayAmount);
        vm.startPrank(repayer);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.repay(marketParams, repayAmount, 0, borrower, "");
        vm.stopPrank();

        (, uint128 borrowSharesAfter,) = morpho.position(marketId, borrower);

        assertLt(borrowSharesAfter, borrowSharesBefore);
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_withdrawCollateral
    // =========================================================================

    /// @notice Test that withdraw collateral decreases user's collateral
    function test_withdrawCollateral_decreasesUserCollateral() public {
        address actor = _getActor();
        uint256 collateralAmount = 1000e18;
        uint256 withdrawAmount = 500e18;

        // First supply collateral
        collateralToken.setBalance(actor, collateralAmount);
        vm.startPrank(actor);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, actor, "");

        (,, uint128 collateralBefore) = morpho.position(marketId, actor);

        // Then withdraw
        morpho.withdrawCollateral(marketParams, withdrawAmount, actor, actor);

        (,, uint128 collateralAfter) = morpho.position(marketId, actor);

        assertEq(collateralAfter, collateralBefore - withdrawAmount);
        vm.stopPrank();
    }

    /// @notice Test that withdraw collateral without authorization reverts
    function test_withdrawCollateral_revertsWithoutAuthorization() public {
        address supplier = address(0x1111);
        address unauthorized = address(0x2222);
        uint256 collateralAmount = 1000e18;

        // Supplier supplies collateral
        collateralToken.setBalance(supplier, collateralAmount);
        vm.startPrank(supplier);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, supplier, "");
        vm.stopPrank();

        // Unauthorized tries to withdraw
        vm.prank(unauthorized);
        vm.expectRevert();
        morpho.withdrawCollateral(marketParams, 100e18, supplier, unauthorized);
    }

    /// @notice Test that withdraw collateral with active borrow reverts if unhealthy
    function test_withdrawCollateral_revertsIfUnhealthy() public {
        address actor = _getActor();
        uint256 collateralAmount = 10000e18;
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 4000e18; // Borrow close to max

        // Setup: supply liquidity
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        // Setup: supply collateral and borrow
        collateralToken.setBalance(actor, collateralAmount);
        vm.startPrank(actor);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, actor, "");
        morpho.borrow(marketParams, borrowAmount, 0, actor, actor);

        // Try to withdraw most collateral (would make position unhealthy)
        vm.expectRevert();
        morpho.withdrawCollateral(marketParams, 9000e18, actor, actor);

        vm.stopPrank();
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_setAuthorizationWithSig
    // =========================================================================

    /// @notice Test that authorization with signature works correctly
    function test_setAuthorizationWithSig_setsCorrectState() public {
        uint256 privateKey = 0x1234;
        address authorizer = vm.addr(privateKey);
        address authorized = address(0x9999);

        Authorization memory authorization = Authorization({
            authorizer: authorizer,
            authorized: authorized,
            isAuthorized: true,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });

        Signature memory sig;
        bytes32 digest = SigUtils.getTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        // Initially should not be authorized
        assertFalse(morpho.isAuthorized(authorizer, authorized));

        // Set authorization with signature
        morpho.setAuthorizationWithSig(authorization, sig);

        // Should now be authorized
        assertTrue(morpho.isAuthorized(authorizer, authorized));
        assertEq(morpho.nonce(authorizer), 1);
    }

    /// @notice Test that authorization with expired signature reverts
    function test_setAuthorizationWithSig_revertsOnExpiredDeadline() public {
        uint256 privateKey = 0x1234;
        address authorizer = vm.addr(privateKey);
        address authorized = address(0x9999);

        Authorization memory authorization = Authorization({
            authorizer: authorizer,
            authorized: authorized,
            isAuthorized: true,
            nonce: 0,
            deadline: block.timestamp - 1
        });

        Signature memory sig;
        bytes32 digest = SigUtils.getTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        vm.expectRevert();
        morpho.setAuthorizationWithSig(authorization, sig);
    }

    /// @notice Test that authorization with wrong nonce reverts
    function test_setAuthorizationWithSig_revertsOnWrongNonce() public {
        uint256 privateKey = 0x1234;
        address authorizer = vm.addr(privateKey);
        address authorized = address(0x9999);

        Authorization memory authorization = Authorization({
            authorizer: authorizer,
            authorized: authorized,
            isAuthorized: true,
            nonce: 5, // Wrong nonce
            deadline: block.timestamp + 1 days
        });

        Signature memory sig;
        bytes32 digest = SigUtils.getTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, digest);

        vm.expectRevert();
        morpho.setAuthorizationWithSig(authorization, sig);
    }

    /// @notice Test that authorization with invalid signature reverts
    function test_setAuthorizationWithSig_revertsOnInvalidSignature() public {
        uint256 privateKey = 0x1234;
        uint256 wrongPrivateKey = 0x5678;
        address authorizer = vm.addr(privateKey);
        address authorized = address(0x9999);

        Authorization memory authorization = Authorization({
            authorizer: authorizer,
            authorized: authorized,
            isAuthorized: true,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });

        Signature memory sig;
        bytes32 digest = SigUtils.getTypedDataHash(morpho.DOMAIN_SEPARATOR(), authorization);
        // Sign with wrong private key
        (sig.v, sig.r, sig.s) = vm.sign(wrongPrivateKey, digest);

        vm.expectRevert();
        morpho.setAuthorizationWithSig(authorization, sig);
    }

    // =========================================================================
    // PROPERTY TESTS FOR morpho_liquidate
    // =========================================================================

    /// @notice Test that liquidation works on unhealthy position
    function test_liquidate_liquidatesUnhealthyPosition() public {
        address borrower = address(0x1111);
        address liquidator = address(0x2222);
        uint256 collateralAmount = 10000e18;
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 4000e18;

        // Setup: supply liquidity
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        // Setup: borrower supplies collateral and borrows
        collateralToken.setBalance(borrower, collateralAmount);
        vm.startPrank(borrower);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, borrower, "");
        morpho.borrow(marketParams, borrowAmount, 0, borrower, borrower);
        vm.stopPrank();

        // Make position unhealthy by dropping oracle price
        oracle.setPrice(ORACLE_PRICE_SCALE / 10); // Drop price by 90%

        // Setup liquidator
        loanToken.setBalance(liquidator, borrowAmount);
        vm.startPrank(liquidator);
        loanToken.approve(address(morpho), type(uint256).max);

        // Liquidate
        uint256 seizedAmount = 1000e18;
        (uint256 returnSeized, uint256 returnRepaid) = morpho.liquidate(marketParams, borrower, seizedAmount, 0, "");

        assertGt(returnSeized, 0);
        assertGt(returnRepaid, 0);
        vm.stopPrank();
    }

    /// @notice Test that liquidation on healthy position reverts
    function test_liquidate_revertsOnHealthyPosition() public {
        address borrower = address(0x1111);
        address liquidator = address(0x2222);
        uint256 collateralAmount = 10000e18;
        uint256 supplyAmount = 5000e18;
        uint256 borrowAmount = 1000e18; // Small borrow, will be healthy

        // Setup: supply liquidity
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        // Setup: borrower supplies collateral and borrows
        collateralToken.setBalance(borrower, collateralAmount);
        vm.startPrank(borrower);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, borrower, "");
        morpho.borrow(marketParams, borrowAmount, 0, borrower, borrower);
        vm.stopPrank();

        // Setup liquidator
        loanToken.setBalance(liquidator, borrowAmount);
        vm.startPrank(liquidator);
        loanToken.approve(address(morpho), type(uint256).max);

        // Try to liquidate healthy position
        vm.expectRevert();
        morpho.liquidate(marketParams, borrower, 100e18, 0, "");

        vm.stopPrank();
    }

    /// @notice Test that liquidation with zero amount reverts
    function test_liquidate_revertsOnZeroAmount() public {
        address borrower = address(0x1111);

        vm.expectRevert();
        morpho.liquidate(marketParams, borrower, 0, 0, "");
    }

    /// @notice Test that liquidation realizes bad debt when collateral insufficient
    function test_liquidate_realizesBadDebt() public {
        address borrower = address(0x1111);
        address liquidator = address(0x2222);
        uint256 collateralAmount = 1000e18;
        uint256 supplyAmount = 10000e18;
        uint256 borrowAmount = 5000e18;

        // Setup: supply liquidity
        loanToken.setBalance(address(this), supplyAmount);
        loanToken.approve(address(morpho), type(uint256).max);
        morpho.supply(marketParams, supplyAmount, 0, address(this), "");

        // Setup: borrower supplies collateral and borrows at high price
        collateralToken.setBalance(borrower, collateralAmount);
        oracle.setPrice(ORACLE_PRICE_SCALE * 100); // High price to allow borrow

        vm.startPrank(borrower);
        collateralToken.approve(address(morpho), type(uint256).max);
        morpho.supplyCollateral(marketParams, collateralAmount, borrower, "");
        morpho.borrow(marketParams, borrowAmount, 0, borrower, borrower);
        vm.stopPrank();

        // Crash the price to make position severely underwater
        oracle.setPrice(ORACLE_PRICE_SCALE / 100);

        // Setup liquidator
        loanToken.setBalance(liquidator, borrowAmount);
        vm.startPrank(liquidator);
        loanToken.approve(address(morpho), type(uint256).max);

        (,, uint128 collateralBefore) = morpho.position(marketId, borrower);

        // Liquidate all collateral
        (uint256 returnSeized, uint256 returnRepaid) = morpho.liquidate(marketParams, borrower, collateralAmount, 0, "");

        assertEq(returnSeized, collateralAmount);
        assertLt(returnRepaid, borrowAmount); // Not all debt repaid due to insufficient collateral

        (,, uint128 collateralAfter) = morpho.position(marketId, borrower);
        assertEq(collateralAfter, 0); // All collateral seized

        vm.stopPrank();
    }

    // =========================================================================
    // HELPER CONTRACTS
    // =========================================================================
}

/// @notice Helper contract for flash loan testing
contract FlashLoanBorrower {
    address public morpho;
    address public token;

    constructor(address _morpho, address _token) {
        morpho = _morpho;
        token = _token;
    }

    function executeFlashLoan(address _token, uint256 amount) external {
        Morpho(morpho).flashLoan(_token, amount, "");
    }

    function onMorphoFlashLoan(uint256 assets, bytes calldata) external {
        require(msg.sender == morpho, "Unauthorized");
        // Approve Morpho to pull back the tokens
        ERC20Mock(token).approve(morpho, assets);
    }
}