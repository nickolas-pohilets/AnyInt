public struct AnyInt: Hashable, SignedInteger {
    var storage: AnyIntStorage

    public static var zero: Self { .init(inline: .zero) }
    public static var one: Self { .init(inline: TinyWord(rawValue: 1)!) }
    public static var minusOne: Self { .init(inline: TinyWord(rawValue: -1)!) }

    init(inline tiny: TinyWord) {
        self.storage = .inline(tiny)
    }

    init(normalised buffer: AnyIntBuffer) {
        self.storage = .buffer(buffer)
    }

    init(normalising buffer: AnyIntBuffer) {
        if let tiny = buffer.truncate() {
            self.storage = .inline(tiny)
        } else {
            self.storage = .buffer(buffer)
        }
    }

    public init(_ value: SignedWord) {
        if let tiny = TinyWord(rawValue: value) {
            self.storage = .inline(tiny)
        } else {
            self.storage = .buffer(AnyIntBuffer.create(value: value))
        }
    }

    public init(words: [UnsignedWord]) {
        let buffer = AnyIntBuffer.create(bits: words.count * UnsignedWord.bitWidth)
        buffer.withUnsafeMutablePointerToElements { ptr in
            for i in 0..<words.count {
                ptr[i] = words[i]
            }
        }
        self.init(normalising: buffer)
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

    var hexDescription: String {
        storage.withWords { words in
            "0x" + (0..<words.count).reversed().map { i in
                String(words[i], radix: 16, uppercase: false)
            }.joined(separator: "_")
        }
    }
}
