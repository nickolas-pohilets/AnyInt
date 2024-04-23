struct WordsView {
    var buffer: UnsafeBufferPointer<UnsignedWord>

    init(start: UnsafePointer<UnsignedWord>, count: Int) {
        self.buffer = .init(start: start, count: count)
    }

    init(_ buffer: UnsafeMutableBufferPointer<UnsignedWord>) {
        self.buffer = UnsafeBufferPointer(buffer)
    }

    var count: Int {
        buffer.count
    }

    var isNegative: Bool {
        return signWord < 0
    }

    var bitWidth: Int {
        return (count - 1) * UnsignedWord.bitWidth + signWord.usedBits
    }

    var signWord: SignedWord {
        return SignedWord(bitPattern: buffer[count - 1])
    }

    subscript(_ index: Int) -> UnsignedWord {
        if index >= count {
            return isNegative ? .max : 0
        }
        if index < 0 {
            return 0
        }
        return buffer[index]
    }

    subscript(bitOffset bitOffset: Int) -> UnsignedWord {
        let bits = bitOffset % UnsignedWord.bitWidth
        let lowIndex = bitOffset / UnsignedWord.bitWidth
        if bits == 0 {
            return self[lowIndex]
        }
        let low = self[lowIndex]
        let high = self[lowIndex + 1]
        return (low >> bits) | (high << (UnsignedWord.bitWidth - bits))
    }
}
