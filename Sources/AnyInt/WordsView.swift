struct WordsView {
    var buffer: UnsafeBufferPointer<UnsignedWord>

    init(start: UnsafePointer<UnsignedWord>, count: Int) {
        self.buffer = .init(start: start, count: count)
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
        if index < count {
            return buffer[index]
        } else {
            return isNegative ? .max : 0
        }
    }
}
