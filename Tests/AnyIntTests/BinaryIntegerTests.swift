import XCTest
@testable import AnyInt

final class BinaryIntegerTests: XCTestCase {
    func testTrailingZeroBitCount() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        XCTAssertEqual(AnyInt(0).trailingZeroBitCount, 1)
        XCTAssertEqual(AnyInt(0).bitWidth, 1)
        XCTAssertEqual(AnyInt(1).trailingZeroBitCount, 0)
        XCTAssertEqual(AnyInt(1).bitWidth, 2)
        XCTAssertEqual(AnyInt(-1).trailingZeroBitCount, 0)
        XCTAssertEqual(AnyInt(-1).bitWidth, 1)
        XCTAssertEqual(AnyInt(4).trailingZeroBitCount, 2)
        XCTAssertEqual(AnyInt(4).bitWidth, 4)
        XCTAssertEqual(AnyInt(-4).trailingZeroBitCount, 2)
        XCTAssertEqual(AnyInt(-4).bitWidth, 3)
        XCTAssertEqual(AnyInt(0x001200fc00).trailingZeroBitCount, 10)
        XCTAssertEqual(AnyInt(0x001200fc00).bitWidth, 30)
        XCTAssertEqual(AnyInt(-0x001200fc00).trailingZeroBitCount, 10)
        XCTAssertEqual(AnyInt(-0x001200fc00).bitWidth, 30)
        XCTAssertEqual(AnyInt(0x0012e0_0000000000000000_0000000000000000).trailingZeroBitCount, 133)
        XCTAssertEqual(AnyInt(0x0012e0_0000000000000000_0000000000000000).bitWidth, 142)
        XCTAssertEqual(AnyInt(-0x0012e0_0000000000000000_0000000000000000).trailingZeroBitCount, 133)
        XCTAssertEqual(AnyInt(-0x0012e0_0000000000000000_0000000000000000).bitWidth, 142)
        XCTAssertEqual(AnyInt(0x00800_0000000000000000_0000000000000000).trailingZeroBitCount, 139)
        XCTAssertEqual(AnyInt(0x00800_0000000000000000_0000000000000000).bitWidth, 141)
        XCTAssertEqual(AnyInt(-0x00800_0000000000000000_0000000000000000).trailingZeroBitCount, 139)
        XCTAssertEqual(AnyInt(-0x00800_0000000000000000_0000000000000000).bitWidth, 140)
    }

    func testInversion() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        func verify(_ value: AnyInt, expected: AnyInt) {
            XCTAssertEqual((~value).hexDescription, expected.hexDescription)
            XCTAssertEqual((~expected).hexDescription, value.hexDescription)
        }
        verify(AnyInt(0), expected: AnyInt(-1))
        verify(AnyInt(-0x40000000_00000000), expected: AnyInt(0x3fffffff_ffffffff))
        verify(AnyInt(0x80000000_00000000), expected: AnyInt(-0x80000000_00000001)) // ...ffff_7fffffffffffffff
        verify(AnyInt(-6543878765654756454390786437874536322042165), expected: AnyInt(6543878765654756454390786437874536322042164))
    }

    func testBitwiseAnd() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        func verify(_ lhs: AnyInt, _ rhs: AnyInt, expected: AnyInt) {
            XCTAssertEqual((lhs & rhs).hexDescription, expected.hexDescription)
            XCTAssertEqual((rhs & lhs).hexDescription, expected.hexDescription)
            var tmp = lhs
            tmp &= rhs
            XCTAssertEqual(tmp.hexDescription, expected.hexDescription)
            tmp = rhs
            tmp &= lhs
            XCTAssertEqual(tmp.hexDescription, expected.hexDescription)
        }

        verify(0x0c26e4, -0x81a0b /* 0xfff7e5f5 */, expected: 0x0424e4)
        verify(-1, -432432488344537483526678, expected: -432432488344537483526678)
        verify(0, -432432488344537483526678, expected: .zero)
        verify(0x3fab452f62705627fedbac34381fde6438, 0x3652fdea736283586341582483927365252738262525, expected: 0x2283402340500403925324242018062420)
    }

    func testBitwiseOr() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        func verify(_ lhs: AnyInt, _ rhs: AnyInt, expected: AnyInt) {
            XCTAssertEqual((lhs | rhs).hexDescription, expected.hexDescription)
            XCTAssertEqual((rhs | lhs).hexDescription, expected.hexDescription)
            var tmp = lhs
            tmp |= rhs
            XCTAssertEqual(tmp.hexDescription, expected.hexDescription)
            tmp = rhs
            tmp |= lhs
            XCTAssertEqual(tmp.hexDescription, expected.hexDescription)
        }

        verify(0x0c26e4, -0x81a0b /* 0xfff7e5f5 */, expected: -0x180b)
        verify(-1, 432432488344537483526678, expected: -1)
        verify(0, -432432488344537483526678, expected: -432432488344537483526678)
        verify(0x3fab452f62705627fedbac34381fde6438, 0x3652fdea736283586341582483927365252738262525, expected: 0x3652fdea737fab5d6f637876a7fefbed353f3ffe653d)
    }

    func testBitwiseXor() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        func verify(_ lhs: AnyInt, _ rhs: AnyInt, expected: AnyInt) {
            XCTAssertEqual((lhs ^ rhs).hexDescription, expected.hexDescription)
            XCTAssertEqual((rhs ^ lhs).hexDescription, expected.hexDescription)
            var tmp = lhs
            tmp ^= rhs
            XCTAssertEqual(tmp.hexDescription, expected.hexDescription)
            tmp = rhs
            tmp ^= lhs
            XCTAssertEqual(tmp.hexDescription, expected.hexDescription)
        }

        verify(0x0c26e4, -0x81a0b /* 0xfff7e5f5 */, expected: -0x43cef)
        verify(-1, 432432488344537483526678, expected: -432432488344537483526679)
        verify(0, 432432488344537483526678, expected: 432432488344537483526678)
        verify(0x3fab452f62705627fedbac34381fde6438, 0x3652fdea736283586341582483927365252738262525, expected: 0x3652fdea735d281d4c232872a46ca8c9111f27f8411d)
    }

    func testShift() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        func verify(_ value: AnyInt, shift: Int, left: AnyInt, right: AnyInt) {
            do {
                let t = value << shift
                XCTAssertEqual(t, left)
                XCTAssertEqual(t >> shift, value)
                XCTAssertEqual((value >> shift).hexDescription, right.hexDescription)
                var tmp = value
                tmp <<= shift
                XCTAssertEqual(tmp, left)
                tmp >>= shift
                XCTAssertEqual(tmp, value)
                tmp >>= shift
                XCTAssertEqual(tmp, right)
            }
            do {
                let t = value >> -shift
                XCTAssertEqual(t, left)
                XCTAssertEqual(t << -shift, value)
                XCTAssertEqual(value << -shift, right)
                var tmp = value
                tmp >>= -shift
                XCTAssertEqual(tmp, left)
                tmp <<= -shift
                XCTAssertEqual(tmp, value)
                tmp <<= -shift
                XCTAssertEqual(tmp, right)
            }
        }
        verify(0, shift: 5, left: 0, right: 0)
        verify(-1, shift: 5, left: -32, right: -1)
        verify(10, shift: 5, left: 320, right: 0)
        verify(-10, shift: 5, left: -320, right: -1)
        verify(1, shift: 100, left: 0x10000000000000000000000000, right: 0)
        verify(1, shift: 101, left: 0x20000000000000000000000000, right: 0)
        verify(0x8aceacc473287dfaec625a6352d5dea7b85cb823786276372ffef3821, shift: 72,
                left: 0x8aceacc473287dfaec625a6352d5dea7b85cb823786276372ffef3821000000000000000000,
                right: 0x8aceacc473287dfaec625a6352d5dea7b85cb82
        )
        verify(-0x8aceacc473287dfaec625a6352d5dea7b85cb823786276372ffef3821, shift: 72,
                left: -0x8aceacc473287dfaec625a6352d5dea7b85cb823786276372ffef3821000000000000000000,
                right: -0x8aceacc473287dfaec625a6352d5dea7b85cb83
        )
    }
}
