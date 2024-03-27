import XCTest
@testable import AnyInt

final class ComparableTests: XCTestCase {
    func testTiny() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        XCTAssertLessThan(AnyInt(integerLiteral: 37), AnyInt(integerLiteral: 42))
        XCTAssertEqual(AnyInt(integerLiteral: 37), AnyInt(integerLiteral: 37))
        XCTAssertGreaterThan(AnyInt(integerLiteral: 42), AnyInt(integerLiteral: 37))

        XCTAssertLessThan(AnyInt(integerLiteral: -42), AnyInt(integerLiteral: -37))
        XCTAssertEqual(AnyInt(integerLiteral: -42), AnyInt(integerLiteral: -42))
        XCTAssertGreaterThan(AnyInt(integerLiteral: -37), AnyInt(integerLiteral: -42))

        XCTAssertLessThan(AnyInt(integerLiteral: -42), AnyInt(integerLiteral: 37))
        XCTAssertGreaterThan(AnyInt(integerLiteral: 37), AnyInt(integerLiteral: -42))
    }

    func testSignsAndWidths() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        XCTAssertLessThan(AnyInt(integerLiteral: 0x37_0000000000000000), AnyInt(integerLiteral: 0x42_0000000000000000))
        XCTAssertEqual(AnyInt(integerLiteral: 0x37_0000000000000000), AnyInt(integerLiteral: 0x37_0000000000000000))
        XCTAssertGreaterThan(AnyInt(integerLiteral: 0x42_0000000000000000), AnyInt(integerLiteral: 0x37_0000000000000000))

        XCTAssertLessThan(AnyInt(integerLiteral: -0x42_0000000000000000), AnyInt(integerLiteral: -0x37_0000000000000000))
        XCTAssertEqual(AnyInt(integerLiteral: -0x42_0000000000000000), AnyInt(integerLiteral: -0x42_0000000000000000))
        XCTAssertGreaterThan(AnyInt(integerLiteral: -0x37_0000000000000000), AnyInt(integerLiteral: -0x42_0000000000000000))

        XCTAssertLessThan(AnyInt(integerLiteral: -0x42_0000000000000000), AnyInt(integerLiteral: 0x37_0000000000000000))
        XCTAssertGreaterThan(AnyInt(integerLiteral: 0x37_0000000000000000), AnyInt(integerLiteral: -0x37_0000000000000000))
    }

    func testSlowPath() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        XCTAssertLessThan(AnyInt(integerLiteral: 0xa_0000000000000000), AnyInt(integerLiteral: 0xa_0000000000000001))
        XCTAssertLessThan(AnyInt(integerLiteral: 0x9_ffffffffffffffff), AnyInt(integerLiteral: 0xa_0000000000000000))
        XCTAssertLessThan(AnyInt(integerLiteral: -0xa_0000000000000001), AnyInt(integerLiteral: -0xa_0000000000000000))
        XCTAssertLessThan(AnyInt(integerLiteral: -0xa_0000000000000000), AnyInt(integerLiteral: -0x9_ffffffffffffffff))
    }

    func testDenormalize() throws {
        let buffer = AnyIntBuffer.create(bits: 100)
        buffer.withPointerToElements { elements in
            for i in 0..<elements.count {
                elements[i] = 0
            }
        }
        XCTAssertNotEqual(AnyInt.zero, AnyInt(storage: .buffer(buffer)))
    }
}
