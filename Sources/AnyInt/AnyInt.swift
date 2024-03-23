// The Swift Programming Language
// https://docs.swift.org/swift-book

// SignedInteger, LosslessStringConvertible
public struct AnyInt: Hashable {
    var storage: AnyIntStorage

    public static var zero: Self { .init(storage: .inline(.zero)) }

    init(storage: AnyIntStorage) {
        self.storage = storage
    }

    public init(_ value: Int64) {
        if let w63 = TinyWord(rawValue: value) {
            self.storage = .inline(w63)
        } else {
            self.storage = .buffer(AnyIntBuffer.create(value: value))
        }
    }

    public var isZero: Bool {
        if case .inline(.zero) = storage {
            return true
        }
        return false
    }

    public var isNegative: Bool {
        storage.isNegative
    }

    public var bitWidth: Int {
        storage.bitWidth
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        if case (.inline(let lhs63), .inline(let rhs63)) = (lhs.storage, rhs.storage) {
            // Can overflow 63 bits, but not 64 bits
            let result = lhs63.rawValue + rhs63.rawValue
            return Self(result)
        }
        return lhs.storage.withWords { lhsView in
            rhs.storage.withWords { rhsView in
                let bits = max(lhsView.bitWidth, rhsView.bitWidth) + (lhsView.isNegative == rhsView.isNegative ? 1 : 0)
                let resultBuffer = AnyIntBuffer.create(bits: bits)
                let carry = resultBuffer.withPointerToElements { result in
                    var carry: Bool = false
                    for i in 0..<result.count {
                        let lhsWord = lhsView[i]
                        let rhsWord = rhsView[i]
                        let a = lhsWord.addingReportingOverflow(rhsWord)
                        let b = a.partialValue.addingReportingOverflow(carry ? 1 : 0)
                        carry = a.overflow || b.overflow
                        result[i] = b.partialValue
                    }
                    return carry
                }
                if lhsView.isNegative != rhsView.isNegative {
                    assert(carry != resultBuffer.isNegative)
                } else {
                    assert(carry == lhsView.isNegative && resultBuffer.isNegative == lhsView.isNegative)
                }
                if let w63 = resultBuffer.truncate() {
                    return Self(storage: .inline(w63))
                } else {
                    return Self(storage: .buffer(resultBuffer))
                }
            }
        }
    }
}
