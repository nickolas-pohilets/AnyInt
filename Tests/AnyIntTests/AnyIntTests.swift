import XCTest
@testable import AnyInt

final class AnyIntTests: XCTestCase {
    func testMemoryLayout() throws {
        XCTAssertEqual(MemoryLayout<TinyWord>.size, MemoryLayout<UInt64>.size)
        XCTAssertEqual(MemoryLayout<TinyWord?>.size, MemoryLayout<UInt64>.size)
        XCTAssertEqual(MemoryLayout<AnyInt>.size, MemoryLayout<UInt64>.size)
    }

    func testTinyWord() {
        XCTAssertNil(TinyWord(rawValue: 0x7fffffffffffffff))
        XCTAssertNil(TinyWord(rawValue: 0x4000000000000000))
        XCTAssertNil(TinyWord(rawValue: -0x4000000000000001))
        XCTAssertNil(TinyWord(rawValue: -0x7fffffffffffffff - 1))

        let valid: [Int64] = [0, 1, -1, 0x3fffffffffffffff, -0x4000000000000000]
        for value in valid {
            let w63 = TinyWord(rawValue: value)
            XCTAssertEqual(w63?.rawValue, value)
            XCTAssertEqual(unsafeBitCast(w63!, to: Int64.self), value & Int64.max)
        }

        XCTAssertEqual(unsafeBitCast(TinyWord?.none, to: Int64.self), Int64.min)
        XCTAssertEqual(unsafeBitCast(AnyInt.zero, to: Int64.self), 0)
    }

    func testIntegerLiteral() {
        if #available(macOS 13.3, *) {
            var a: AnyInt = 0
            XCTAssertEqual(a, AnyInt(Int64(0)))
            a = -1
            XCTAssertEqual(a, AnyInt(Int64(-1)))
            a = 1
            XCTAssertEqual(a, AnyInt(Int64(1)))
            a = 0x3fffffffffffffff
            XCTAssertEqual(a, AnyInt(Int64(0x3fffffffffffffff)))
            a = -0x4000000000000000
            XCTAssertEqual(a, AnyInt(Int64(-0x4000000000000000)))

            a = 0x4000000000000000
            XCTAssertEqual(a.storage.buffer?.count, 1)
            a = 0x7fffffffffffffff
            XCTAssertEqual(a.storage.buffer?.count, 1)
            a = 0x8000000000000000
            XCTAssertEqual(a.storage.buffer?.count, 2)

            a = -0x4000000000000001
            XCTAssertEqual(a.storage.buffer?.count, 1)
            a = -0x8000000000000000
            XCTAssertEqual(a.storage.buffer?.count, 1)
            a = -0x8000000000000001
            XCTAssertEqual(a.storage.buffer?.count, 2)
        }
    }

    func testAddition() {
        if #available(macOS 13.3, *) {
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
    }
}
