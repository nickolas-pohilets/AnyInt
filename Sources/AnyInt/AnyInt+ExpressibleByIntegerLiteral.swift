@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
extension AnyInt: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = StaticBigInt
    public init(integerLiteral value: StaticBigInt) {
        if value.bitWidth <= TinyWord.bitWidth {
            let tiny = TinyWord(bitPattern: value[wordIndex: 0])!
            self.init(storage: .inline(tiny))
        } else {
            let buffer = AnyIntBuffer.create(bits: value.bitWidth)
            buffer.withPointerToElements { words in
                for i in 0..<words.count {
                    words[i] = value[wordIndex: i]
                }
            }
            self.init(storage: .buffer(buffer))
        }
    }
}

@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
private extension StaticBigInt {
    subscript(wordIndex wordIndex: Int) -> UnsignedWord {
        switch MemoryLayout<UnsignedWord>.size / MemoryLayout<UInt>.size {
        case 1:
            let value: UInt = self[wordIndex]
            return UnsignedWord(value)
        case 2:
            let low: UInt = self[2 * wordIndex]
            let high: UInt = self[2 * wordIndex + 1]
            return (UnsignedWord(high) << 32) | (UnsignedWord(low))
        default:
            fatalError()
        }
    }
}
