import XCTest
@testable import AnyInt

final class AdditiveArithmeticTests: XCTestCase {
    func testAddition() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        do {
            let a = AnyInt(integerLiteral: 0x2874872316835231) + AnyInt(integerLiteral: 0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x3fffffffffffffff))
            XCTAssertEqual(a.storage.inline?.rawValue, 0x3fffffffffffffff)
        }
        do {
            let a = AnyInt(integerLiteral: 0x2874872316835232) + AnyInt(integerLiteral: 0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x4000000000000000))
            XCTAssertEqual(a.storage.buffer?.count, 1)
        }
        do {
            let a = AnyInt(integerLiteral: -0x2874872316835232) + AnyInt(integerLiteral: -0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: -0x4000000000000000))
            XCTAssertEqual(a.storage.inline?.rawValue, -0x4000000000000000)
        }
        do {
            let a = AnyInt(integerLiteral: -0x2874872316835233) + AnyInt(integerLiteral: -0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: -0x4000000000000001))
            XCTAssertEqual(a.storage.buffer?.count, 1)
        }
        do {
            let a = AnyInt(integerLiteral: 0x1_0000000000000000_0000000000000000) + AnyInt(integerLiteral: -1)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x0_ffffffffffffffff_ffffffffffffffff))
            XCTAssertEqual(a.storage.buffer?.count, 3)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000001) + AnyInt(integerLiteral: -1)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x8000000000000000_0000000000000000))
            XCTAssertEqual(a.storage.buffer?.count, 3)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000000) + AnyInt(integerLiteral: -1)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x7fffffffffffffff_ffffffffffffffff))
            XCTAssertEqual(a.storage.buffer?.count, 2)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000000) + AnyInt(integerLiteral: -0x7fffffffffffffffffffffffffffffbe)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x42))
            XCTAssertEqual(a.storage.inline?.rawValue, 0x42)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000000) + AnyInt(integerLiteral: -0x8000000000000000_0000000000000001)
            XCTAssertEqual(a, AnyInt(integerLiteral: -1))
            XCTAssertEqual(a.storage.inline?.rawValue, -1)
        }
    }

    func testSubstraction() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
        do {
            let a = AnyInt(integerLiteral: 0x2874872316835231) - AnyInt(integerLiteral: -0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x3fffffffffffffff))
            XCTAssertEqual(a.storage.inline?.rawValue, 0x3fffffffffffffff)
        }
        do {
            let a = AnyInt(integerLiteral: 0x2874872316835232) - AnyInt(integerLiteral: -0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x4000000000000000))
            XCTAssertEqual(a.storage.buffer?.count, 1)
        }
        do {
            let a = AnyInt(integerLiteral: -0x2874872316835232) - AnyInt(integerLiteral: 0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: -0x4000000000000000))
            XCTAssertEqual(a.storage.inline?.rawValue, -0x4000000000000000)
        }
        do {
            let a = AnyInt(integerLiteral: -0x2874872316835233) - AnyInt(integerLiteral: 0x178b78dce97cadce)
            XCTAssertEqual(a, AnyInt(integerLiteral: -0x4000000000000001))
            XCTAssertEqual(a.storage.buffer?.count, 1)
        }
        do {
            let a = AnyInt(integerLiteral: 0x1_0000000000000000_0000000000000000) - AnyInt(integerLiteral: 1)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x0_ffffffffffffffff_ffffffffffffffff))
            XCTAssertEqual(a.storage.buffer?.count, 3)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000001) - AnyInt(integerLiteral: 1)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x8000000000000000_0000000000000000))
            XCTAssertEqual(a.storage.buffer?.count, 3)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000000) - AnyInt(integerLiteral: 1)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x7fffffffffffffff_ffffffffffffffff))
            XCTAssertEqual(a.storage.buffer?.count, 2)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000000) - AnyInt(integerLiteral: 0x7fffffffffffffffffffffffffffffbe)
            XCTAssertEqual(a, AnyInt(integerLiteral: 0x42))
            XCTAssertEqual(a.storage.inline?.rawValue, 0x42)
        }
        do {
            let a = AnyInt(integerLiteral: 0x8000000000000000_0000000000000000) - AnyInt(integerLiteral: 0x8000000000000000_0000000000000001)
            XCTAssertEqual(a, AnyInt(integerLiteral: -1))
            XCTAssertEqual(a.storage.inline?.rawValue, -1)
        }
    }
}
