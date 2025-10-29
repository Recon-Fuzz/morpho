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
import {ERC20Mock} from "src/mocks/ERC20Mock.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";

abstract contract MorphoTargets is
    BaseTargetFunctions,
    Properties
{
    using MarketParamsLib for MarketParams;
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    // === CLAMPED HANDLERS === //
    // These handlers reduce the input space to prevent reverts and improve coverage

    function morpho_supply_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf) public asActor {
        // Clamp assets to actor's balance
        uint256 actorBalance = ERC20Mock(marketParams.loanToken).balanceOf(_getActor());
        if (actorBalance == 0) return;

        assets = (assets % actorBalance) + 1;

        morpho_supply(marketParams, assets, 0, onBehalf, "");
    }

    function morpho_supplyShares_clamped(MarketParams memory marketParams, uint256 shares, address onBehalf) public asActor {
        // Clamp shares to reasonable range based on total supply shares
        Id id = marketParams.id();
        (,,uint128 totalSupplyShares,,,) = morpho.market(id);

        // Only use shares-based supply if there's already supply in the market
        if (totalSupplyShares == 0) return;

        shares = (shares % totalSupplyShares) + 1;

        morpho_supplyShares(marketParams, shares, onBehalf, "");
    }

    function morpho_withdraw_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor {
        // Clamp assets to available supply
        Id id = marketParams.id();
        (uint256 supplyShares,,) = morpho.position(id, onBehalf);
        (uint128 totalSupplyAssets,uint128 totalSupplyShares,,,,) = morpho.market(id);

        if (supplyShares == 0) return;
        if (totalSupplyShares == 0) return;

        // Calculate max withdrawable assets
        uint256 maxAssets = (supplyShares * totalSupplyAssets) / totalSupplyShares;
        if (maxAssets == 0) return;

        assets = (assets % maxAssets) + 1;

        morpho_withdraw(marketParams, assets, 0, onBehalf, receiver);
    }

    function morpho_supplyCollateral_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf) public asActor {
        // Clamp assets to actor's collateral token balance
        uint256 actorBalance = ERC20Mock(marketParams.collateralToken).balanceOf(_getActor());
        if (actorBalance == 0) return;

        assets = (assets % actorBalance) + 1;

        morpho_supplyCollateral(marketParams, assets, onBehalf, "");
    }

    function morpho_borrow_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor {
        // Clamp borrow to available liquidity
        Id id = marketParams.id();
        (uint128 totalSupplyAssets,,uint128 totalBorrowAssets,,,) = morpho.market(id);

        uint256 availableLiquidity = totalSupplyAssets > totalBorrowAssets ?
            totalSupplyAssets - totalBorrowAssets : 0;
        if (availableLiquidity == 0) return;

        assets = (assets % availableLiquidity) + 1;

        morpho_borrow(marketParams, assets, 0, onBehalf, receiver);
    }

    function morpho_repay_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf) public asActor {
        // Clamp repay to borrowed amount
        Id id = marketParams.id();
        (,uint128 borrowShares,) = morpho.position(id, onBehalf);
        (,,uint128 totalBorrowAssets,uint128 totalBorrowShares,,) = morpho.market(id);

        if (borrowShares == 0) return;
        if (totalBorrowShares == 0) return;

        uint256 maxRepay = ((borrowShares * totalBorrowAssets) / totalBorrowShares) + 1; // +1 for rounding

        // Also clamp to actor's token balance
        uint256 actorBalance = ERC20Mock(marketParams.loanToken).balanceOf(_getActor());
        maxRepay = maxRepay < actorBalance ? maxRepay : actorBalance;

        if (maxRepay == 0) return;

        assets = (assets % maxRepay) + 1;

        morpho_repay(marketParams, assets, 0, onBehalf, "");
    }

    function morpho_withdrawCollateral_clamped(MarketParams memory marketParams, uint256 assets, address onBehalf, address receiver) public asActor {
        // Clamp to available collateral
        Id id = marketParams.id();
        (,,uint128 collateral) = morpho.position(id, onBehalf);

        if (collateral == 0) return;

        // For simplicity, withdraw up to 50% of collateral to maintain health factor
        // This is conservative but helps avoid health factor violations
        uint256 maxWithdraw = collateral / 2;
        if (maxWithdraw == 0) maxWithdraw = 1;

        assets = (assets % maxWithdraw) + 1;

        morpho_withdrawCollateral(marketParams, assets, onBehalf, receiver);
    }

    function morpho_flashLoan_clamped(address token, uint256 assets) public asActor {
        // Clamp to available balance in Morpho
        uint256 available = ERC20Mock(token).balanceOf(address(morpho));
        if (available == 0) return;

        assets = (assets % available) + 1;

        morpho_flashLoan(token, assets, "");
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function morpho_accrueInterest(MarketParams memory marketParams) public asActor {
        morpho.accrueInterest(marketParams);
    }

    function morpho_borrow(MarketParams memory marketParams, uint256 assets, uint256 shares, address onBehalf, address receiver) public asActor {
        morpho.borrow(marketParams, assets, shares, onBehalf, receiver);
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

    // === SHARE-BASED VARIANTS === //
    // These handlers call the same functions but use shares instead of assets
    // This helps cover the alternative code paths that were missing in baseline coverage

    function morpho_supplyShares(MarketParams memory marketParams, uint256 shares, address onBehalf, bytes memory data) public asActor {
        // Supply using shares instead of assets (assets=0, shares>0)
        morpho.supply(marketParams, 0, shares, onBehalf, data);
    }

    function morpho_withdrawShares(MarketParams memory marketParams, uint256 shares, address onBehalf, address receiver) public asActor {
        // Withdraw using shares instead of assets (assets=0, shares>0)
        morpho.withdraw(marketParams, 0, shares, onBehalf, receiver);
    }

    function morpho_borrowShares(MarketParams memory marketParams, uint256 shares, address onBehalf, address receiver) public asActor {
        // Borrow using shares instead of assets (assets=0, shares>0)
        morpho.borrow(marketParams, 0, shares, onBehalf, receiver);
    }

    function morpho_repayShares(MarketParams memory marketParams, uint256 shares, address onBehalf, bytes memory data) public asActor {
        // Repay using shares instead of assets (assets=0, shares>0)
        morpho.repay(marketParams, 0, shares, onBehalf, data);
    }

    function morpho_liquidateByRepaidShares(MarketParams memory marketParams, address borrower, uint256 repaidShares, bytes memory data) public asActor {
        // Liquidate using repaidShares instead of seizedAssets (seizedAssets=0, repaidShares>0)
        morpho.liquidate(marketParams, borrower, 0, repaidShares, data);
    }
}