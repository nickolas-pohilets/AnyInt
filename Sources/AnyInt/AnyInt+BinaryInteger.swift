extension AnyInt: BinaryInteger {
    public var words: [UInt] {
        storage.withWords { w in
            (0..<w.count).map { w[$0 ] }
        }
    }

    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.init(exactly: source)
    }

    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(exactly: source)
    }

    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(exactly: source)
    }

    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        fatalError()
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        fatalError()
    }
    
    public var trailingZeroBitCount: Int {
        if isZero { return bitWidth }
        return storage.withWords { words in
            var bits: Int = 0
            var k = 0
            while words[k] == 0 {
                bits += UnsignedWord.bitWidth
                k += 1
            }
            bits += words[k].trailingZeroBitCount
            return bits
        }
    }
    
    public static func / (lhs: AnyInt, rhs: AnyInt) -> AnyInt {
        rhs.dividing(lhs).quotient
    }

    public static func /= (lhs: inout AnyInt, rhs: AnyInt) {
        lhs = lhs / rhs
    }

    public static func % (lhs: AnyInt, rhs: AnyInt) -> AnyInt {
        rhs.dividing(lhs).remainder
    }
    
    public static func %= (lhs: inout AnyInt, rhs: AnyInt) {
        lhs = lhs % rhs
    }

    public static prefix func ~ (x: AnyInt) -> AnyInt {
        switch x.storage {
        case .inline(let tiny):
            let result = TinyWord(bitPattern: ~tiny.bitPattern)!
            return AnyInt(storage: .inline(result))
        case .buffer(let buffer):
            let result = AnyIntBuffer.create(bits: x.bitWidth)
            result.withPointerToElements { elements in
                buffer.withPointerToElements { sourceElements in
                    for i in 0..<elements.count {
                        elements[i] = ~sourceElements[i]
                    }
                }
            }
            return AnyInt(storage: .buffer(result))
        }
    }

    public static func &= (lhs: inout AnyInt, rhs: AnyInt) {
        bitwise(lhs: &lhs, rhs: rhs, op: (&))
    }
    
    public static func |= (lhs: inout AnyInt, rhs: AnyInt) {
        bitwise(lhs: &lhs, rhs: rhs, op: (|))
    }
    
    public static func ^= (lhs: inout AnyInt, rhs: AnyInt) {
        bitwise(lhs: &lhs, rhs: rhs, op: (^))
    }

    private static func bitwise(lhs: inout AnyInt, rhs: AnyInt, op: (UnsignedWord, UnsignedWord) -> UnsignedWord) {
        if case (.inline(let lhsTiny), .inline(let rhsTiny)) = (lhs.storage, rhs.storage) {
            let result = TinyWord(bitPattern: op(lhsTiny.bitPattern, rhsTiny.bitPattern))!
            lhs.storage = .inline(result)
        } else {
            let bitWidth = Swift.max(lhs.bitWidth, rhs.bitWidth)
            let result = lhs.storage.withWords { lhsView in
                rhs.storage.withWords { rhsView in
                    let result = AnyIntBuffer.create(bits: bitWidth)
                    result.withPointerToElements { elements in
                        for i in 0..<elements.count {
                            elements[i] = op(lhsView[i], rhsView[i])
                        }
                    }
                    return result
                }
            }
            if let tiny = result.truncate() {
                lhs.storage = .inline(tiny)
            } else {
                lhs.storage = .buffer(result)
            }
        }
    }

    public static func >>= <RHS: BinaryInteger>(lhs: inout AnyInt, rhs: RHS) {
        fatalError()
    }

    public static func <<= <RHS: BinaryInteger>(lhs: inout AnyInt, rhs: RHS) {
        fatalError()
    }

    public func dividing(_ dividend: AnyInt) -> (quotient: AnyInt, remainder: AnyInt) {
        fatalError()
    }
}
