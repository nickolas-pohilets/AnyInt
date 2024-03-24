@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
extension AnyInt: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = StaticBigInt
    public init(integerLiteral value: StaticBigInt) {
        if value.bitWidth <= TinyWord.bitWidth {
            let tiny = TinyWord(bitPattern: value[0])!
            self.init(storage: .inline(tiny))
        } else {
            let buffer = AnyIntBuffer.create(bits: value.bitWidth)
            buffer.withPointerToElements { words in
                for i in 0..<words.count {
                    words[i] = value[i]
                }
            }
            self.init(storage: .buffer(buffer))
        }
    }
}

