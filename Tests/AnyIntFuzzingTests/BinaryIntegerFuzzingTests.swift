import XCTest
@testable import AnyInt_MicroWord

final class BinaryIntegerFuzzingTests: XCTestCase {
    func testWordSize() {
        XCTAssertEqual(UnsignedWord.bitWidth, 8)
    }
}
