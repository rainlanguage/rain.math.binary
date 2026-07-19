// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {
    LibCtPop,
    CTPOP_M1,
    CTPOP_M2,
    CTPOP_M4,
    CTPOP_M8,
    CTPOP_M16,
    CTPOP_M32,
    CTPOP_M64,
    CTPOP_M128,
    CTPOP_H01
} from "../../../src/lib/LibCtPop.sol";

/// @title LibCtPopTest
/// CTPOP (count population) is a function that counts the number of bits set in
/// a `uint256`. The reference implementations are taken directly from Wikipedia.
/// https://en.wikipedia.org/wiki/Hamming_weight
contract LibCtPopTest is Test {
    /// We should be able to count the number of bits set when we simply set a
    /// sequence of bits from the low bit to some mid bit.
    function testCtPopUnshuffled(uint8 n) external pure {
        uint256 x = (1 << n) - 1;
        uint256 ct = LibCtPop.ctpop(x);
        assertEq(n, ct);
        uint256 ctSlow = LibCtPop.ctpopSlow(x);
        assertEq(ct, ctSlow);
    }

    /// The distribution of bits in the underlying `uint256` should not matter.
    function testCtPopShuffled(uint8 n, bytes32 rand) external pure {
        uint256 x = (1 << n) - 1;
        uint256 y = 0;

        // Fisher-yates to show pop count can handle any distribution of bits.
        for (uint256 i = 256; i > 0; i--) {
            rand = keccak256(bytes.concat(rand));
            uint256 offset = uint256(rand) % i;
            uint256 lowMask = (1 << offset) - 1;
            uint256 low = x & lowMask;
            uint256 high = x & ~lowMask;
            uint256 bit = (high >> offset) & 1;
            x = (high >> 1) | low;
            y = y | (bit << (i - 1));
        }

        uint256 ct = LibCtPop.ctpop(y);
        assertEq(n, ct);
        uint256 ctSlow = LibCtPop.ctpopSlow(y);
        assertEq(ct, ctSlow);
    }

    function testCtPopReference(uint256 x) external pure {
        uint256 ct = LibCtPop.ctpop(x);
        uint256 ctSlow = LibCtPop.ctpopSlow(x);
        assertEq(ct, ctSlow);
    }

    function testCtPop256EdgeCase() external pure {
        uint256 x = type(uint256).max;
        uint256 ct = LibCtPop.ctpop(x);
        assertEq(256, ct);
        uint256 ctSlow = LibCtPop.ctpopSlow(x);
        assertEq(ct, ctSlow);
    }

    function testCtPop0() external pure {
        uint256 x = 0;
        uint256 ct = LibCtPop.ctpop(x);
        assertEq(0, ct);
        uint256 ctSlow = LibCtPop.ctpopSlow(x);
        assertEq(ct, ctSlow);
    }

    function testCtPop1() external pure {
        uint256 x = 1;
        uint256 ct = LibCtPop.ctpop(x);
        assertEq(1, ct);
        uint256 ctSlow = LibCtPop.ctpopSlow(x);
        assertEq(ct, ctSlow);
    }

    /// A lone bit in the highest position is counted, deterministically
    /// pinning the top of the range rather than relying on fuzz coverage.
    function testCtPopLoneHighBit() external pure {
        uint256 x = 1 << 255;
        assertEq(1, LibCtPop.ctpop(x));
        assertEq(1, LibCtPop.ctpopSlow(x));
    }

    /// Build the alternating mask with `width` bits set then `width` bits
    /// clear, starting from the low bit, across the whole word.
    function altMask(uint256 width) internal pure returns (uint256 mask) {
        unchecked {
            uint256 chunk = (1 << width) - 1;
            for (uint256 i = 0; i < 256; i += 2 * width) {
                mask |= chunk << i;
            }
        }
    }

    /// Every mask constant is pinned against an independent re-derivation so
    /// a corrupted constant cannot hide behind ctpop and ctpopSlow sharing it.
    function testMaskConstantsRederived() external pure {
        assertEq(altMask(1), CTPOP_M1);
        assertEq(altMask(2), CTPOP_M2);
        assertEq(altMask(4), CTPOP_M4);
        assertEq(altMask(8), CTPOP_M8);
        assertEq(altMask(16), CTPOP_M16);
        assertEq(altMask(32), CTPOP_M32);
        assertEq(altMask(64), CTPOP_M64);
        assertEq(altMask(128), CTPOP_M128);

        uint256 h01 = 0;
        for (uint256 i = 0; i < 256; i += 8) {
            h01 |= uint256(1) << i;
        }
        assertEq(h01, CTPOP_H01);
    }
}
