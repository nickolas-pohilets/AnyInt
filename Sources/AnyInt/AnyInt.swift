// SignedInteger, LosslessStringConvertible
public struct AnyInt: Hashable {
    var storage: AnyIntStorage

    public static var zero: Self { .init(storage: .inline(.zero)) }

    init(storage: AnyIntStorage) {
        self.storage = storage
    }

    public init(_ value: Int64) {
        if let tiny = TinyWord(rawValue: value) {
            self.storage = .inline(tiny)
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
}
