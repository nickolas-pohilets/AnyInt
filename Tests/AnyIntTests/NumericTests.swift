import XCTest
@testable import AnyInt

final class NumericTests: XCTestCase {
    func checkImpl(_ lhs: AnyInt, _ rhs: AnyInt, expected: AnyInt, words: Int?) {
        let result = lhs * rhs
        XCTAssertEqual(result, expected, "\(result.hexDescription) != \(expected.hexDescription)")
        if let words {
            XCTAssertEqual(result.storage.buffer?.count, words)
        } else {
            XCTAssertNotNil(result.storage.inline)
        }
    }

    func check(_ lhs: AnyInt, _ rhs: AnyInt, expected: AnyInt, words: Int?) {
        checkImpl(lhs, rhs, expected: expected, words: words)
        checkImpl(rhs, lhs, expected: expected, words: words)
    }

    func testTiny() throws {
        check(42, 37, expected: 1554, words: nil)
        check(42, -37, expected: -1554, words: nil)
        check(-42, 37, expected: -1554, words: nil)
        check(-42, -37, expected: 1554, words: nil)
    }

    func testTinyToWord() throws {
        check(2147548211, 3198754300, expected: 6869479074393557300, words: 1)
        check(2147548211, -3198754300, expected: -6869479074393557300, words: 1)
        check(-2147548211, 3198754300, expected: -6869479074393557300, words: 1)
        check(-2147548211, -3198754300, expected: 6869479074393557300, words: 1)
    }

    func testTinyToPair() throws {
        check(23847627469, 489762387962, expected: 11679670976445626128178, words: 2)
        check(23847627469, -489762387962, expected: -11679670976445626128178, words: 2)
        check(-23847627469, 489762387962, expected: -11679670976445626128178, words: 2)
        check(-23847627469, -489762387962, expected: 11679670976445626128178, words: 2)
    }

    func testLongWithZero() throws {
        check(11679670976445626128178, 0, expected: 0, words: nil)
        check(0, 11679670976445626128178, expected: 0, words: nil)
    }

    func testLong() throws {
        check(11679670976445626128178, 1, expected: 11679670976445626128178, words: 2)
        check(11679670976445626128178, -1, expected: -11679670976445626128178, words: 2)
        check(-11679670976445626128178, 1, expected: -11679670976445626128178, words: 2)
        check(-11679670976445626128178, -1, expected: 11679670976445626128178, words: 2)

        check(11679670976445626128178, 23, expected: 268632432458249400948094, words: 2)
        check(11679670976445626128178, -23, expected: -268632432458249400948094, words: 2)
        check(-11679670976445626128178, 23, expected: -268632432458249400948094, words: 2)
        check(-11679670976445626128178, -23, expected: 268632432458249400948094, words: 2)

        check(11679670976445626128178, 87230740937490832, expected: 1018826353181458998118564233386531864096, words: 3)
        check(11679670976445626128178, -87230740937490832, expected: -1018826353181458998118564233386531864096, words: 3)
        check(-11679670976445626128178, 87230740937490832, expected: -1018826353181458998118564233386531864096, words: 3)
        check(-11679670976445626128178, -87230740937490832, expected: 1018826353181458998118564233386531864096, words: 3)

        check(0x7fffffffffffffff_ffffffffffffffff, 0x7fffffffffffffff_ffffffffffffffff,
              expected: 0x3fffffffffffffffffffffffffffffff00000000000000000000000000000001, words: 4)
        check(0x7fffffffffffffff_ffffffffffffffff, -0x8000000000000000_0000000000000000,
              expected: -0x3fffffffffffffffffffffffffffffff80000000000000000000000000000000, words: 4)
        check(-0x8000000000000000_0000000000000000, -0x8000000000000000_0000000000000000,
              expected: 0x4000000000000000000000000000000000000000000000000000000000000000, words: 4)
    }
}
