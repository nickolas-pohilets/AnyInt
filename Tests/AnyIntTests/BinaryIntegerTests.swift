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
}
