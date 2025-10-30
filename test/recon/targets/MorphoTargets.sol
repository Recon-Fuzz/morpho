// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "src/Morpho.sol";

abstract contract MorphoTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    // Reasonable limits for clamping to reduce reverts
    uint256 constant MAX_SUPPLY_AMOUNT = type(uint88).max / 100; // Prevent overflow, stay within initial balance
    uint256 constant MAX_BORROW_AMOUNT = type(uint88).max / 1000; // Much smaller to ensure collateralization
    uint256 constant MAX_COLLATERAL_AMOUNT = type(uint88).max / 100;

    /// === CLAMPED SUPPLY HANDLERS ===

    /// @notice Clamped supply function - constrains amounts to valid ranges
    function morpho_supply_clamped(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        // Clamp market params to default market
        marketParams = defaultMarketParams;

        // Clamp amounts to reasonable values
        // Ensure exactly one is zero as required by Morpho
        if (assets % 2 == 0) {
            assets = (assets % MAX_SUPPLY_AMOUNT) + 1; // At least 1
            shares = 0;
        } else {
            assets = 0;
            shares = (shares % MAX_SUPPLY_AMOUNT) + 1; // At least 1
        }

        // Clamp onBehalf to current actor or another valid actor
        if (onBehalf == address(0) || uint256(uint160(onBehalf)) % 2 == 0) {
            onBehalf = _getActor();
        } else {
            address[] memory actors = _getActors();
            onBehalf = actors[uint256(uint160(onBehalf)) % actors.length];
        }

        morpho_supply(marketParams, assets, shares, onBehalf, data);
    }

    /// @notice Supply pure assets (no shares) with clamped market
    function morpho_supply_clamped_assetsOnly(uint256 assets) public asActor {
        assets = (assets % MAX_SUPPLY_AMOUNT) + 1;
        morpho_supply(defaultMarketParams, assets, 0, _getActor(), hex"");
    }

    /// === CLAMPED WITHDRAW HANDLERS ===

    /// @notice Clamped withdraw function - only withdraws what was supplied
    function morpho_withdraw_clamped(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        marketParams = defaultMarketParams;

        // Get current supply position
        address actor = _getActor();
        (uint256 supplyShares, , ) = morpho.position(defaultMarketId, actor);

        // Clamp to available supply (use shares-based withdrawal to avoid rounding issues)
        // If no supply, this will revert naturally in the underlying call
        shares = supplyShares > 0 ? (shares % supplyShares) + 1 : shares;
        assets = 0;

        onBehalf = actor;
        receiver = actor;

        morpho_withdraw(marketParams, assets, shares, onBehalf, receiver);
    }

    /// === CLAMPED COLLATERAL HANDLERS ===

    /// @notice Clamped supply collateral function
    function morpho_supplyCollateral_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data) public asActor {
        marketParams = defaultMarketParams;

        // Clamp to reasonable collateral amount
        assets = (assets % MAX_COLLATERAL_AMOUNT) + 1;

        // Clamp onBehalf
        address actor = _getActor();
        if (onBehalf == address(0) || uint256(uint160(onBehalf)) % 3 == 0) {
            onBehalf = actor;
        }

        morpho_supplyCollateral(marketParams, assets, onBehalf, data);
    }

    /// @notice Clamped withdraw collateral - only withdraws safe amounts
    function morpho_withdrawCollateral_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor {
        marketParams = defaultMarketParams;
        address actor = _getActor();

        // Get current collateral position
        (, uint256 borrowShares, uint256 collateral) = morpho.position(defaultMarketId, actor);

        // Clamp based on collateral and borrow status
        // If we have borrows, only withdraw a small portion to maintain health
        if (borrowShares > 0 && collateral > 0) {
            // Withdraw at most 10% of collateral to maintain health
            assets = (assets % (collateral / 10 + 1)) + 1;
        } else if (collateral > 0) {
            // No borrows, can withdraw up to full collateral
            assets = (assets % collateral) + 1;
        }
        // If no collateral, will revert naturally

        onBehalf = actor;
        receiver = actor;

        morpho_withdrawCollateral(marketParams, assets, onBehalf, receiver);
    }

    /// === CLAMPED BORROW HANDLERS ===

    /// @notice Clamped borrow function - ensures sufficient collateral first
    function morpho_borrow_clamped(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        marketParams = defaultMarketParams;
        address actor = _getActor();

        // Get current position
        (, uint256 borrowShares, uint256 collateral) = morpho.position(defaultMarketId, actor);

        // Need collateral to borrow
        if (collateral == 0) {
            // Supply some collateral first
            uint256 collateralAmt = MAX_COLLATERAL_AMOUNT / 10;
            collateralToken.approve(address(morpho), collateralAmt);
            morpho.supplyCollateral(marketParams, collateralAmt, actor, hex"");
            collateral = collateralAmt;
        }

        // Calculate max safe borrow (conservatively using LLTV * collateral value)
        // With lltv=0.8 and oracle price at 1e36, and same decimals:
        // maxBorrow = collateral * lltv = collateral * 0.8
        uint256 maxSafeBorrow = (collateral * 8) / 10;

        // Account for existing borrows
        if (borrowShares > 0) {
            (,, uint128 totalBorrowAssets, uint128 totalBorrowShares,,) = morpho.market(defaultMarketId);
            uint256 currentBorrow = uint256(borrowShares) * uint256(totalBorrowAssets) / uint256(totalBorrowShares);
            if (currentBorrow < maxSafeBorrow) {
                maxSafeBorrow -= currentBorrow;
            } else {
                maxSafeBorrow = 1; // Will revert naturally but avoids early return
            }
        }

        // Clamp borrow to safe amount (use 50% of max for safety margin)
        uint256 safeBorrow = maxSafeBorrow / 2;
        safeBorrow = safeBorrow > 0 ? safeBorrow : 1; // Minimum 1 to avoid division by zero

        // Use assets-based borrow
        assets = (assets % safeBorrow) + 1;
        shares = 0;

        onBehalf = actor;
        receiver = actor;

        morpho_borrow(marketParams, assets, shares, onBehalf, receiver);
    }

    /// === CLAMPED REPAY HANDLERS ===

    /// @notice Clamped repay function - only repays existing debt
    function morpho_repay_clamped(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        marketParams = defaultMarketParams;
        address actor = _getActor();

        // Get current borrow position
        (, uint256 borrowShares, ) = morpho.position(defaultMarketId, actor);

        // Repay using shares to avoid rounding issues
        // If no debt, will revert naturally
        shares = borrowShares > 0 ? (shares % borrowShares) + 1 : shares;
        assets = 0;

        onBehalf = actor;

        morpho_repay(marketParams, assets, shares, onBehalf, data);
    }

    /// === CLAMPED LIQUIDATE HANDLERS ===

    /// @notice Clamped liquidate - attempts to create and liquidate unhealthy positions
    function morpho_liquidate_clamped(MarketParams memory marketParams, address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data) public asActor {
        marketParams = defaultMarketParams;

        // Pick a borrower from actors
        address[] memory actors = _getActors();
        borrower = actors[uint256(uint160(borrower)) % actors.length];

        // Check if borrower has an unhealthy position
        (, uint256 borrowShares, uint256 collateral) = morpho.position(defaultMarketId, borrower);

        // Clamp to small portion of collateral
        // If no borrow or no collateral, will revert naturally
        seizedAssets = collateral > 0 ? (seizedAssets % (collateral / 10 + 1)) + 1 : seizedAssets;
        repaidShares = 0;

        morpho_liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
    }

    /// === CLAMPED FLASHLOAN HANDLERS ===

    /// @notice Clamped flashloan - only borrows available liquidity
    function morpho_flashLoan_clamped(address token, uint256 assets, bytes memory data) public asActor {
        // Use loan token
        token = address(loanToken);

        // Check available balance in morpho
        uint256 available = loanToken.balanceOf(address(morpho));

        // Clamp to available amount
        // If no liquidity, will revert naturally
        assets = available > 0 ? (assets % available) + 1 : assets;

        morpho_flashLoan(token, assets, data);
    }

    /// === CLAMPED AUTHORIZATION HANDLERS ===

    /// @notice Clamped authorization - uses valid addresses
    function morpho_setAuthorization_clamped(address authorized, bool newIsAuthorized) public asActor {
        // Pick from actors
        address[] memory actors = _getActors();
        authorized = actors[uint256(uint160(authorized)) % actors.length];

        // Toggle based on current state to avoid revert
        bool currentAuth = morpho.isAuthorized(_getActor(), authorized);
        newIsAuthorized = !currentAuth;

        morpho_setAuthorization(authorized, newIsAuthorized);
    }

    /// === CLAMPED ACCRUE INTEREST ===

    /// @notice Clamped accrue interest - always uses default market
    function morpho_accrueInterest_clamped() public {
        morpho_accrueInterest(defaultMarketParams);
    }

    /// === WORKFLOW SHORTCUT HANDLERS ===

    /// @notice Complete supply-borrow workflow with clamped values
    function workflow_supplyCollateralAndBorrow_clamped(uint256 collateralAmt, uint256 borrowAmt) public asActor {
        address actor = _getActor();

        // Clamp collateral
        collateralAmt = (collateralAmt % MAX_COLLATERAL_AMOUNT) + 1;

        // Supply collateral
        morpho.supplyCollateral(defaultMarketParams, collateralAmt, actor, hex"");

        // Calculate safe borrow (50% of collateral value with lltv)
        uint256 maxBorrow = (collateralAmt * 8 / 10) / 2;
        maxBorrow = maxBorrow > 0 ? maxBorrow : 1; // Minimum 1 to avoid division by zero

        borrowAmt = (borrowAmt % maxBorrow) + 1;

        // Borrow
        morpho.borrow(defaultMarketParams, borrowAmt, 0, actor, actor);
    }

    /// @notice Supply loan tokens workflow
    function workflow_supplyLoan_clamped(uint256 assets) public asActor {
        assets = (assets % MAX_SUPPLY_AMOUNT) + 1;
        morpho.supply(defaultMarketParams, assets, 0, _getActor(), hex"");
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function morpho_accrueInterest(MarketParams memory marketParams) public asActor {
        morpho.accrueInterest(marketParams);
    }

    function morpho_borrow(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        morpho.borrow(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_createMarket(MarketParams memory marketParams) public asActor {
        morpho.createMarket(marketParams);
    }

    function morpho_flashLoan(address token, uint256 assets, bytes memory data) public asActor {
        morpho.flashLoan(token, assets, data);
    }

    function morpho_liquidate(MarketParams memory marketParams, address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data) public asActor {
        morpho.liquidate(marketParams, borrower, seizedAssets, repaidShares, data);
    }

    function morpho_repay(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        morpho.repay(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public asActor {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_setAuthorizationWithSig(Authorization memory authorization, Signature memory signature) public asActor {
        morpho.setAuthorizationWithSig(authorization, signature);
    }

    function morpho_supply(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, bytes memory data) public asActor {
        morpho.supply(marketParams, assets, shares, onBehalf, data);
    }

    function morpho_supplyCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, bytes memory data) public asActor {
        morpho.supplyCollateral(marketParams, assets, onBehalf, data);
    }

    function morpho_withdraw(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        morpho.withdraw(marketParams, assets, shares, onBehalf, receiver);
    }

    function morpho_withdrawCollateral(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor {
        morpho.withdrawCollateral(marketParams, assets, onBehalf, receiver);
    }
}