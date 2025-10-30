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

abstract contract AdminTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    // Constants for clamping
    uint256 constant MAX_FEE = 0.25e18; // 25% max fee as per Morpho protocol
    uint256 constant MAX_LLTV = 0.99e18; // 99% max LLTV

    /// === CLAMPED ADMIN HANDLERS ===

    /// @notice Clamped enable IRM - uses deployed IRM or zero address
    function morpho_enableIrm_clamped(address irmAddress) public asAdmin {
        // Use either the deployed IRM or zero address (both are valid)
        if (uint256(uint160(irmAddress)) % 2 == 0) {
            irmAddress = address(irm);
        } else {
            irmAddress = address(0);
        }
        morpho_enableIrm(irmAddress);
    }

    /// @notice Clamped enable LLTV - uses valid LLTV values
    function morpho_enableLltv_clamped(uint256 lltvValue) public asAdmin {
        // Clamp to valid LLTV range (0 to MAX_LLTV)
        lltvValue = lltvValue % (MAX_LLTV + 1);
        morpho_enableLltv(lltvValue);
    }

    /// @notice Clamped set fee - uses default market and valid fee range
    function morpho_setFee_clamped(uint256 newFee) public asAdmin {
        // Clamp to valid fee range (0 to 25%)
        newFee = newFee % (MAX_FEE + 1);
        morpho_setFee(defaultMarketParams, newFee);
    }

    /// @notice Clamped set fee recipient - uses actors or admin
    function morpho_setFeeRecipient_clamped(address recipient) public asAdmin {
        // Use either an actor or admin as fee recipient
        address[] memory actors = _getActors();
        if (uint256(uint160(recipient)) % 3 == 0) {
            recipient = address(this); // Admin
        } else {
            recipient = actors[uint256(uint160(recipient)) % actors.length];
        }
        morpho_setFeeRecipient(recipient);
    }

    /// @notice Clamped set owner - uses actors or keeps current owner
    function morpho_setOwner_clamped(address newOwner) public asAdmin {
        // Use either an actor or keep current owner (to avoid losing control)
        address[] memory actors = _getActors();
        if (uint256(uint160(newOwner)) % 4 == 0) {
            newOwner = address(this); // Keep current owner
        } else {
            newOwner = actors[uint256(uint160(newOwner)) % actors.length];
        }
        morpho_setOwner(newOwner);
    }

    // Admin-only functions that require owner privileges (unclamped versions)
    function morpho_enableIrm(address irm) public asAdmin {
        morpho.enableIrm(irm);
    }

    function morpho_enableLltv(uint256 lltv) public asAdmin {
        morpho.enableLltv(lltv);
    }

    function morpho_setFee(MarketParams memory marketParams, uint256 newFee) public asAdmin {
        morpho.setFee(marketParams, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public asAdmin {
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_setOwner(address newOwner) public asAdmin {
        morpho.setOwner(newOwner);
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///
}