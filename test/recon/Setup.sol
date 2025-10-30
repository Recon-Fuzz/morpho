// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils} from "@recon/Utils.sol";

// Your deps
import "src/Morpho.sol";
import {MarketParams, Id} from "src/interfaces/IMorpho.sol";
import {OracleMock} from "src/mocks/OracleMock.sol";
import {IrmMock} from "src/mocks/IrmMock.sol";
import {ORACLE_PRICE_SCALE} from "src/libraries/ConstantsLib.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    using MarketParamsLib for MarketParams;

    // Configuration constants
    uint8 internal constant DECIMALS = 18;
    uint256 internal constant DEFAULT_TEST_LLTV = 0.8 ether; // 80% LLTV

    // Core contracts
    Morpho public morpho;
    OracleMock public oracle;
    IrmMock public irm;

    // Market configuration
    MarketParams public marketParams;
    Id public marketId;

    // Asset references
    address public loanToken;
    address public collateralToken;

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        // 1. Add additional actors
        _addActor(address(0x100)); // Actor 1
        _addActor(address(0x200)); // Actor 2

        // 2. Deploy tokens using AssetManager
        loanToken = _newAsset(DECIMALS);
        collateralToken = _newAsset(DECIMALS);

        // 3. Deploy oracle and set price to standard scale
        oracle = new OracleMock();
        oracle.setPrice(ORACLE_PRICE_SCALE); // 1e36 = 1:1 price ratio

        // 4. Deploy interest rate model
        irm = new IrmMock();

        // 5. Deploy Morpho with this contract as owner
        morpho = new Morpho(address(this));

        // 6. Configure Morpho: Enable IRM and LLTV
        morpho.enableIrm(address(0)); // Enable zero address IRM (required for some operations)
        morpho.enableIrm(address(irm)); // Enable our IRM
        morpho.enableLltv(0); // Enable zero LLTV
        morpho.enableLltv(DEFAULT_TEST_LLTV); // Enable default test LLTV (80%)

        // 7. Create market with loan token, collateral token, oracle, irm, and lltv
        marketParams = MarketParams({
            loanToken: loanToken,
            collateralToken: collateralToken,
            oracle: address(oracle),
            irm: address(irm),
            lltv: DEFAULT_TEST_LLTV
        });
        marketId = marketParams.id();
        morpho.createMarket(marketParams);

        // 8. Set up approval array for Morpho to access tokens
        address[] memory approvalArray = new address[](1);
        approvalArray[0] = address(morpho);

        // 9. Finalize asset deployment (mints to actors and sets approvals)
        // This gives all actors tokens and approves the morpho contract
        _finalizeAssetDeployment(_getActors(), approvalArray, type(uint88).max);
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor

    modifier asAdmin {
        vm.prank(address(this));
        _;
    }

    modifier asActor {
        vm.prank(address(_getActor()));
        _;
    }
}
