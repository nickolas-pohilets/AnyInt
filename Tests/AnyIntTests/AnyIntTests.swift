import XCTest
@testable import AnyInt

final class AnyIntTests: XCTestCase {
    func testMemoryLayout() throws {
        XCTAssertEqual(MemoryLayout<TinyWord>.size, MemoryLayout<UInt64>.size)
        XCTAssertEqual(MemoryLayout<TinyWord?>.size, MemoryLayout<UInt64>.size)
        XCTAssertEqual(MemoryLayout<AnyInt>.size, MemoryLayout<UInt64>.size)
    }

    func testTinyWord() throws {
        XCTAssertNil(TinyWord(rawValue: 0x7fffffffffffffff))
        XCTAssertNil(TinyWord(rawValue: 0x4000000000000000))
        XCTAssertNil(TinyWord(rawValue: -0x4000000000000001))
        XCTAssertNil(TinyWord(rawValue: -0x7fffffffffffffff - 1))

        let valid: [Int64] = [0, 1, -1, 0x3fffffffffffffff, -0x4000000000000000]
        for value in valid {
            let tiny = TinyWord(rawValue: value)
            XCTAssertEqual(tiny?.rawValue, value)
            XCTAssertEqual(unsafeBitCast(try XCTUnwrap(tiny), to: Int64.self), value & Int64.max)
        }

        XCTAssertEqual(unsafeBitCast(TinyWord?.none, to: Int64.self), Int64.min)
        XCTAssertEqual(unsafeBitCast(AnyInt.zero, to: Int64.self), 0)
    }

    func testIntegerLiteral() throws {
        guard #available(macOS 13.3, *) else { throw XCTSkip() }
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
