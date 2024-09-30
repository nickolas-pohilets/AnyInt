import XCTest
@testable import AnyInt

final class AnyIntStorageTests: XCTestCase {
    func testCreateEmpty() {
        let storage = AnyIntStorage.create(words: [], isSigned: true)
        XCTAssertEqual(storage.inline?.bitPattern, 0)
    }

    func testIsUnique() {
        var storage = AnyIntStorage.inline(.zero)
        XCTAssertFalse(storage.isUniqueBuffer())
        storage = AnyIntStorage.create(words: [0x123, 0x456], isSigned: true)
        XCTAssertTrue(storage.isUniqueBuffer())
        var copy = storage
        XCTAssertFalse(storage.isUniqueBuffer() || copy.isUniqueBuffer())
    }
}
