import XCTest
@testable import AnyInt_MicroWord

func getRange(bitWidth: Int) -> ClosedRange<Int64> {
    if bitWidth == 64 {
        return (.min)...(.max)
    }
    let max: Int64 = 1 << (bitWidth - 1)
    return (-max)...(max - 1)
}

func makeNumber() -> Int64 {
    let bitWidth = Int.random(in: 1...64)
    let range = getRange(bitWidth: bitWidth)
    return Int64.random(in: range)
}

func makeNonZeroNumber() -> Int64 {
    while true {
        let x = makeNumber()
        if x != 0 {
            return x
        }
    }
}

func asAnyInt(_ x: Int64) -> AnyInt {
    var bits = UInt64(bitPattern: x)
    var bytes: [UInt8] = []
    for _ in 0..<8 {
        let b = UInt8(truncatingIfNeeded: bits)
        bytes.append(b)
        bits >>= 8
    }
    return AnyInt(words: bytes)
}

final class BinaryIntegerFuzzingTests: XCTestCase {
    func testWordSize() {
        XCTAssertEqual(UnsignedWord.bitWidth, 8)
    }

    func testDivide(dividend: Int64, divisor: Int64) {
        let quotient = dividend / divisor
        let remainder = dividend % divisor

        let dr = asAnyInt(divisor)
        let dd = asAnyInt(dividend)
        print("\(dd.hexDescription) / \(dr.hexDescription)")
        let (q, r) = dr.dividing(dd)

        XCTAssertEqual(q.hexDescription, asAnyInt(quotient).hexDescription, "\(dividend) / \(divisor)")
        XCTAssertEqual(r.hexDescription, asAnyInt(remainder).hexDescription, "\(dividend) % \(divisor)")
    }

    func testIt() {
        testDivide(dividend: 86073967129978, divisor: 39908202)
        testDivide(dividend: -252754925140, divisor: -128)
        testDivide(dividend: 804, divisor: -24)
        testDivide(dividend: 0, divisor: 8429525891759525)
    }

    func testDivision() throws {
        for _ in 0..<1000000 {
            testDivide(dividend: makeNumber(), divisor: makeNonZeroNumber())
        }
    }
}
