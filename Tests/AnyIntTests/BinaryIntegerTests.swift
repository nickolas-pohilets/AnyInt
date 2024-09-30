import XCTest
@testable import AnyInt

final class BinaryIntegerTests: XCTestCase {
    func testTrailingZeroBitCount() throws {
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

    func testDivision() throws {
        func verifyImpl(_ dividend: AnyInt, _ divisor: AnyInt, quotient: AnyInt, remainder: AnyInt) {
            do {
                let (q, r) = divisor.dividing(dividend)
                XCTAssertEqual(q.hexDescription, quotient.hexDescription, "\(dividend.hexDescription) / \(divisor.hexDescription)")
                XCTAssertEqual(r.hexDescription, remainder.hexDescription, "\(dividend.hexDescription) % \(divisor.hexDescription)")
            }
        }

        func verify(_ dividend: AnyInt, divisor: AnyInt, quotient: AnyInt, remainder: AnyInt) {
            verifyImpl(dividend, divisor, quotient: quotient, remainder: remainder)
            verifyImpl(dividend, -divisor, quotient: -quotient, remainder: remainder)
            verifyImpl(-dividend, divisor, quotient: -quotient, remainder: -remainder)
            verifyImpl(-dividend, -divisor, quotient: quotient, remainder: -remainder)
        }

        verify(0x3fffffffffffffff, divisor: 1, quotient: 0x3fffffffffffffff, remainder: 0)
        verify(0x4000000000000000, divisor: 1, quotient: 0x4000000000000000, remainder: 0)
        verify(0x3fffffffffffffff, divisor: 7, quotient: 0x924924924924924, remainder: 3)
        verify(0x7fffffffffffffff, divisor: 1, quotient: 0x7fffffffffffffff, remainder: 0)
        verify(0x8000000000000000, divisor: 1, quotient: 0x8000000000000000, remainder: 0)
        verify(0x7688c8b373d86489f362fcc72dd74724a1a044e3c17a, divisor: 0x219842895789347598374981,
               quotient: 0x387426127469123098308, remainder: 0x37272)
        verify(0, divisor: 0x219842895789347598374981, quotient: 0, remainder: 0)
        verify(0x7688c8b373d86489f362fcc72dd74724a1a044e3c17a, divisor: 0x8000000000000000,
               quotient: 0xed119166e7b0c913e6c5f98e5bae, remainder: 0x4724a1a044e3c17a)
        verify(0x18943b1891ca1481075d6800000000003128763123942901dd9249cedc6bd6fdf14540000000000000000,
               divisor: 0x8000000000000000_0000000000000000_ffffffffffffffff,
               quotient: 0x31287631_239429020ebac_ffffffffffffffff,
               remainder: 0x7fffffffffffffff0000000000000001ffffffffffffffff)
    }

    func testFromFloatingPointExact() throws {
        func verify(source: Float, expected: AnyInt?) {
            do {
                let converted = AnyInt(exactly: source)
                XCTAssertEqual(converted?.hexDescription, expected?.hexDescription)
            }
            do {
                let converted = AnyInt(exactly: -source)
                XCTAssertEqual(converted?.hexDescription, expected.map { (-$0).hexDescription })
            }
        }
        verify(source: 0, expected: 0)
        verify(source: 0.5, expected: nil)
        verify(source: 0.999999, expected: nil)
        verify(source: 4, expected: 4)
        verify(source: 123, expected: 123)
        verify(source: 123456786051166514360985072406712287232, expected: 123456786051166514360985072406712287232)
        verify(source: .nan, expected: nil)
        verify(source: .infinity, expected: nil)
        verify(source: .leastNormalMagnitude, expected: nil)
        verify(source: .leastNonzeroMagnitude, expected: nil)
        verify(source: .greatestFiniteMagnitude, expected: 0xffffff0000000000_0000000000000000)
    }

    func testFromFloatingPointRoundingTowardsZero() throws {
        func verify(source: Float, expected: AnyInt) {
            do {
                let converted = AnyInt(source)
                XCTAssertEqual(converted.hexDescription, expected.hexDescription)
            }
            do {
                let converted = AnyInt(-source)
                XCTAssertEqual(converted.hexDescription, (-expected).hexDescription)
            }
        }
        verify(source: 0, expected: 0)
        verify(source: 0.5, expected: 0)
        verify(source: 0.999999, expected: 0)
        verify(source: 4, expected: 4)
        verify(source: 123, expected: 123)
        verify(source: 123456786051166514360985072406712287232, expected: 123456786051166514360985072406712287232)
        verify(source: .leastNormalMagnitude, expected: 0)
        verify(source: .leastNonzeroMagnitude, expected: 0)
        verify(source: .greatestFiniteMagnitude, expected: 0xffffff0000000000_0000000000000000)
    }
}
 
