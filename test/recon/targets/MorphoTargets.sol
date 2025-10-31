// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";
import {MockERC20} from "@recon/MockERC20.sol";

import "src/Morpho.sol";

abstract contract MorphoTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    // Clamped handler for supply
    function morpho_supply_clamped(uint256 assets) public asActor {
        address actor = _getActor();
        uint256 actorBalance = MockERC20(marketParams.loanToken).balanceOf(actor);

        // Clamp assets to actor's balance, +1 to allow depositing full balance
        assets = assets % (actorBalance + 1);

        // Call unclamped handler with clamped values
        morpho_supply(marketParams, assets, 0, actor, bytes(""));
    }

    // Clamped handler for withdraw
    function morpho_withdraw_clamped(uint256 shares) public asActor {
        address actor = _getActor();
        (uint256 actorShares,,) = morpho.position(marketId, actor);

        // Clamp shares to actor's supply shares, +1 to allow withdrawing all
        shares = shares % (actorShares + 1);

        // Call unclamped handler with clamped values
        morpho_withdraw(marketParams, 0, shares, actor, actor);
    }

    // Clamped handler for borrow
    function morpho_borrow_clamped(uint256 assets) public asActor {
        address actor = _getActor();

        // Get available liquidity
        (uint128 totalSupplyAssets,, uint128 totalBorrowAssets,,,) = morpho.market(marketId);
        uint256 availableLiquidity = totalSupplyAssets > totalBorrowAssets
            ? totalSupplyAssets - totalBorrowAssets
            : 0;

        // Clamp assets to available liquidity, +1 to allow borrowing maximum
        assets = assets % (availableLiquidity + 1);

        // Call unclamped handler with clamped values
        morpho_borrow(marketParams, assets, 0, actor, actor);
    }

    // Clamped handler for repay
    function morpho_repay_clamped(uint256 shares) public asActor {
        address actor = _getActor();
        (, uint128 actorBorrowShares,) = morpho.position(marketId, actor);

        // Clamp shares to actor's borrow shares, +1 to allow repaying all
        shares = shares % (uint256(actorBorrowShares) + 1);

        // Call unclamped handler with clamped values
        morpho_repay(marketParams, 0, shares, actor, bytes(""));
    }

    // Clamped handler for supplyCollateral
    function morpho_supplyCollateral_clamped(uint256 assets) public asActor {
        address actor = _getActor();
        uint256 actorBalance = MockERC20(marketParams.collateralToken).balanceOf(actor);

        // Clamp assets to actor's balance, +1 to allow supplying full balance
        assets = assets % (actorBalance + 1);

        // Call unclamped handler with clamped values
        morpho_supplyCollateral(marketParams, assets, actor, bytes(""));
    }

    // Clamped handler for withdrawCollateral
    function morpho_withdrawCollateral_clamped(uint256 assets) public asActor {
        address actor = _getActor();
        (,, uint128 actorCollateral) = morpho.position(marketId, actor);

        // Clamp assets to actor's collateral, +1 to allow withdrawing all
        assets = assets % (uint256(actorCollateral) + 1);

        // Call unclamped handler with clamped values
        morpho_withdrawCollateral(marketParams, assets, actor, actor);
    }

    // Clamped handler for liquidate - uses assets
    function morpho_liquidate_clamped_assets(uint256 seizedAssets) public asActor {
        address borrower = _getActor();
        (,, uint128 borrowerCollateral) = morpho.position(marketId, borrower);

        // Clamp seizedAssets to borrower's collateral, +1 to allow seizing maximum
        seizedAssets = seizedAssets % (uint256(borrowerCollateral) + 1);

        // Call unclamped handler with clamped values (repaidShares = 0)
        morpho_liquidate(marketParams, borrower, seizedAssets, 0, bytes(""));
    }

    // Clamped handler for liquidate - uses shares
    function morpho_liquidate_clamped_shares(uint256 repaidShares) public asActor {
        address borrower = _getActor();
        (, uint128 borrowerShares,) = morpho.position(marketId, borrower);

        // Clamp repaidShares to borrower's borrow shares, +1 to allow repaying maximum
        repaidShares = repaidShares % (uint256(borrowerShares) + 1);

        // Call unclamped handler with clamped values (seizedAssets = 0)
        morpho_liquidate(marketParams, borrower, 0, repaidShares, bytes(""));
    }

    // Clamped handler for flashLoan
    function morpho_flashLoan_clamped(uint256 assets) public asActor {
        address token = marketParams.loanToken;
        uint256 morphoBalance = MockERC20(token).balanceOf(address(morpho));

        // Clamp assets to Morpho's balance, +1 to allow borrowing maximum
        assets = assets % (morphoBalance + 1);

        // Call unclamped handler with clamped values
        morpho_flashLoan(token, assets, bytes(""));
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