extension AnyInt: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = StaticBigInt
    public init(integerLiteral value: StaticBigInt) {
        let bitWidth = value.bitWidth
        if bitWidth <= TinyWord.bitWidth {
            let tiny = TinyWord(bitPattern: value[word: 0])!
            self.init(inline: tiny)
        } else {
            let buffer = AnyIntBuffer.create(bits: bitWidth)
            buffer.withPointerToElements { words in
                for i in 0..<words.count {
                    words[i] = value[word: i]
                }
            }
            self.init(normalised: buffer)
        }
        assert(self.bitWidth == bitWidth)
    }
}

private extension StaticBigInt {
    subscript(word index: Int) -> UnsignedWord {
        resizedWord(index: index, as: UnsignedWord.self) { index in
            self[index]
        }
    }
}
