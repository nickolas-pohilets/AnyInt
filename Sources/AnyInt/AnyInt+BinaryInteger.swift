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
        fatalError()
    }

    public static func /= (lhs: inout AnyInt, rhs: AnyInt) {
        fatalError()
    }

    public static func % (lhs: AnyInt, rhs: AnyInt) -> AnyInt {
        fatalError()
    }
    
    public static func %= (lhs: inout AnyInt, rhs: AnyInt) {
        fatalError()
    }

    public static prefix func ~ (x: AnyInt) -> AnyInt {
        fatalError()
    }

    public static func &= (lhs: inout AnyInt, rhs: AnyInt) {
        fatalError()
    }
    
    public static func |= (lhs: inout AnyInt, rhs: AnyInt) {
        fatalError()
    }
    
    public static func ^= (lhs: inout AnyInt, rhs: AnyInt) {
        fatalError()
    }

    public static func >>= <RHS: BinaryInteger>(lhs: inout AnyInt, rhs: RHS) {
        fatalError()
    }

    public static func <<= <RHS: BinaryInteger>(lhs: inout AnyInt, rhs: RHS) {
        fatalError()
    }
}
