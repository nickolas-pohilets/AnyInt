@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
extension AnyInt: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = StaticBigInt
    public init(integerLiteral value: StaticBigInt) {
        let bitWidth = value.bitWidth
        if bitWidth <= TinyWord.bitWidth {
            let tiny = TinyWord(bitPattern: value[0])!
            self.init(inline: tiny)
        } else {
            let buffer = AnyIntBuffer.create(bits: bitWidth)
            buffer.withPointerToElements { words in
                for i in 0..<words.count {
                    words[i] = value[i]
                }
            }
            self.init(normalised: buffer)
        }
        assert(self.bitWidth == bitWidth)
    }
}

