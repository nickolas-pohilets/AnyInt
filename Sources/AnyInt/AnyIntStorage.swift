enum AnyIntStorage: Hashable {
    case inline(TinyWord)
    case buffer(AnyIntBuffer)

    var count: Int {
        switch self {
        case .inline: return 1
        case .buffer(let buffer): return buffer.count
        }
    }

    static func create<W: RandomAccessCollection<UnsignedWord>>(words: W, isSigned: Bool) -> Self where W.Index == Int {
        if isSigned {
            return create(signed: words)
        } else {
            return create(unsigned: words)
        }
    }

    static func create<W: RandomAccessCollection<UnsignedWord>>(signed words: W) -> Self where W.Index == Int {
        if words.isEmpty {
            return .inline(.zero)
        }
        let isNegative = SignedWord(bitPattern: words[words.count - 1]) < 0
        let filler: UnsignedWord = isNegative ? .max : 0
        var k: Int = words.count
        while k > 1 && words[k - 1] == filler && (SignedWord(bitPattern: words[k - 2]) < 0) == isNegative {
            k -= 1
        }
        if k == 1 {
            let value = SignedWord(bitPattern: words[0])
            if let tiny = TinyWord(rawValue: value) {
                return .inline(tiny)
            }
        }
        let bitWidth = (k - 1) * UnsignedWord.bitWidth + SignedWord(bitPattern: words[k - 1]).usedBits
        let buffer = AnyIntBuffer.create(bits: bitWidth)
        buffer.withPointerToElements { elements in
            for i in 0..<elements.count {
                if i < k {
                    elements[i] = words[i]
                } else {
                    elements[i] = filler
                }
            }
        }
        return .buffer(buffer)
    }

    static func create<W: RandomAccessCollection<UnsignedWord>>(unsigned words: W) -> Self where W.Index == Int {
        var k: Int = words.count
        while k > 0 && words[k - 1] == 0 {
            k -= 1
        }
        if k == 0 {
            return .inline(.zero)
        }
        if k == 1 {
            if let value = SignedWord(exactly: words[0]) {
                if let tiny = TinyWord(rawValue: value) {
                    return .inline(tiny)
                }
            }
        }
        let bitWidth = k * UnsignedWord.bitWidth - words[k - 1].leadingZeroBitCount + 1
        let buffer = AnyIntBuffer.create(bits: bitWidth)
        buffer.withPointerToElements { elements in
            for i in 0..<elements.count {
                if i < k {
                    elements[i] = words[i]
                } else {
                    elements[i] = 0
                }
            }
        }
        return .buffer(buffer)
    }

    func withWords<R>(_ body: (WordsView) throws -> R) rethrows -> R {
        switch self {
        case .inline(let tiny):
            let value = tiny.bitPattern
            return try withUnsafePointer(to: value) { ptr in
                let view = WordsView(start: ptr, count: 1)
                return try body(view)
            }
        case .buffer(let buffer):
            return try buffer.withPointerToElements { buf in
                let view = WordsView(start: buf.baseAddress!, count: buf.count)
                return try body(view)
            }
        }
    }

    var isNegative: Bool {
        switch self {
        case .inline(let tiny):
            return tiny.isNegative
        case .buffer(let buffer):
            return buffer.isNegative
        }
    }

    var bitWidth: Int {
        switch self {
        case .inline(let tiny): return tiny.bitWidth
        case .buffer(let buffer): return buffer.bitWidth
        }
    }

    var inline: TinyWord? {
        switch self {
        case .inline(let tiny): return tiny
        case .buffer: return nil
        }
    }

    var buffer: AnyIntBuffer? {
        switch self {
        case .inline: return nil
        case .buffer(let buffer): return buffer
        }
    }
}
