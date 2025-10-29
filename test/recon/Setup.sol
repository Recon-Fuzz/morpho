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
import {ERC20Mock} from "src/mocks/ERC20Mock.sol";
import {OracleMock} from "src/mocks/OracleMock.sol";
import {IrmMock} from "src/mocks/IrmMock.sol";
import {MarketParams, Id} from "src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "src/libraries/MarketParamsLib.sol";
import "src/libraries/ConstantsLib.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    using MarketParamsLib for MarketParams;

    Morpho morpho;
    ERC20Mock loanToken;
    ERC20Mock collateralToken;
    OracleMock oracle;
    IrmMock irm;

    address owner;
    address feeRecipient;

    MarketParams marketParams;
    Id marketId;

    uint256 constant DEFAULT_LLTV = 0.8 ether;

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        owner = address(this);
        feeRecipient = address(0x1234);

        // Deploy Morpho
        morpho = new Morpho(owner);

        // Deploy mocks
        loanToken = new ERC20Mock();
        collateralToken = new ERC20Mock();
        oracle = new OracleMock();
        irm = new IrmMock();

        // Configure oracle
        oracle.setPrice(ORACLE_PRICE_SCALE);

        // Enable IRM and LLTV
        morpho.enableIrm(address(0));
        morpho.enableIrm(address(irm));
        morpho.enableLltv(0);
        morpho.enableLltv(DEFAULT_LLTV);
        morpho.setFeeRecipient(feeRecipient);

        // Create market
        marketParams = MarketParams({
            loanToken: address(loanToken),
            collateralToken: address(collateralToken),
            oracle: address(oracle),
            irm: address(irm),
            lltv: DEFAULT_LLTV
        });

        marketId = marketParams.id();
        morpho.createMarket(marketParams);
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
