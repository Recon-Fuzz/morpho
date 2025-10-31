// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {ORACLE_PRICE_SCALE} from "src/libraries/ConstantsLib.sol";


// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();

        targetContract(address(this));
    }

    // forge test --match-test test_crytic -vvv
    function test_crytic() public {
        // TODO: add failing property tests here for debugging
    }

    /// === PHASE 2 UNIT TESTS === ///

    // 1. morpho_accrueInterest - no prerequisite
    function test_morpho_accrueInterest() public {
        morpho_accrueInterest(marketParams);
    }

    // 2. morpho_setAuthorization - no prerequisite
    function test_morpho_setAuthorization() public {
        address authorized = _getActors()[0];
        morpho_setAuthorization(authorized, true);
    }

    // 3. morpho_supply - no prerequisite
    function test_morpho_supply() public {
        uint256 assets = 1e18;
        address onBehalf = _getActor();
        morpho_supply(marketParams, assets, 0, onBehalf, "");
    }

    // 4. morpho_supplyCollateral - no prerequisite
    function test_morpho_supplyCollateral() public {
        uint256 assets = 1e18;
        address onBehalf = _getActor();
        morpho_supplyCollateral(marketParams, assets, onBehalf, "");
    }

    // 5. morpho_withdraw - supply must be called first
    function test_morpho_withdraw() public {
        uint256 assets = 1e18;
        address onBehalf = _getActor();
        // Supply first
        morpho_supply(marketParams, assets, 0, onBehalf, "");
        // Then withdraw
        morpho_withdraw(marketParams, assets, 0, onBehalf, onBehalf);
    }

    // 6. morpho_withdrawCollateral - supplyCollateral must be called first
    function test_morpho_withdrawCollateral() public {
        uint256 assets = 1e18;
        address onBehalf = _getActor();
        // Supply collateral first
        morpho_supplyCollateral(marketParams, assets, onBehalf, "");
        // Then withdraw collateral
        morpho_withdrawCollateral(marketParams, assets, onBehalf, onBehalf);
    }

    // 7. morpho_flashLoan - SKIPPED: requires IMorphoFlashLoanCallback implementation
    // This is documented in reverting_handlers.md

    // 8. morpho_borrow - supply and supplyCollateral must be called first
    function test_morpho_borrow() public {
        uint256 supplyAmount = 10e18;
        uint256 collateralAmount = 5e18;
        uint256 borrowAmount = 1e18;

        // Supply liquidity first
        morpho_supply(marketParams, supplyAmount, 0, _getActor(), "");

        // Switch to another actor to borrow
        switchActor(1);
        address borrower = _getActor();

        // Supply collateral
        morpho_supplyCollateral(marketParams, collateralAmount, borrower, "");

        // Then borrow
        morpho_borrow(marketParams, borrowAmount, 0, borrower, borrower);
    }

    // 9. morpho_repay - borrow must be called first
    function test_morpho_repay() public {
        uint256 supplyAmount = 10e18;
        uint256 collateralAmount = 5e18;
        uint256 borrowAmount = 1e18;

        // Supply liquidity first
        morpho_supply(marketParams, supplyAmount, 0, _getActor(), "");

        // Switch to another actor to borrow
        switchActor(1);
        address borrower = _getActor();

        // Supply collateral and borrow
        morpho_supplyCollateral(marketParams, collateralAmount, borrower, "");
        morpho_borrow(marketParams, borrowAmount, 0, borrower, borrower);

        // Then repay
        morpho_repay(marketParams, borrowAmount, 0, borrower, "");
    }

    // 10. morpho_setAuthorizationWithSig - SKIPPED: requires valid signature
    // This requires off-chain signature generation which is complex for unit tests

    // 11. morpho_liquidate - borrow must be called first and position must be unhealthy
    function test_morpho_liquidate() public {
        uint256 supplyAmount = 10e18;
        uint256 collateralAmount = 2e18;
        uint256 borrowAmount = 1.5e18;

        // Supply liquidity first
        morpho_supply(marketParams, supplyAmount, 0, _getActor(), "");

        // Switch to another actor to borrow
        switchActor(1);
        address borrower = _getActor();

        // Supply collateral and borrow
        morpho_supplyCollateral(marketParams, collateralAmount, borrower, "");
        morpho_borrow(marketParams, borrowAmount, 0, borrower, borrower);

        // Make position unhealthy by decreasing collateral price (10% of original)
        // With 80% LLTV, collateral worth 0.2e18 can only support 0.16e18 borrow
        // But we borrowed 1.5e18, so position becomes unhealthy
        oracle.setPrice(ORACLE_PRICE_SCALE / 10);

        // Switch to liquidator
        switchActor(0);

        // Liquidate the unhealthy position
        morpho_liquidate(marketParams, borrower, 0, borrowAmount, "");
    }
}