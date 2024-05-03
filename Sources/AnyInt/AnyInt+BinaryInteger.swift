extension AnyInt: BinaryInteger {
    public var words: [UInt] {
        storage.withWords { (w: WordsView) -> [UInt] in
            let k = (w.count * UnsignedWord.bitWidth + UInt.bitWidth - 1) / UInt.bitWidth
            return (0..<k).map { (index) -> UInt in
                resizedWord(index: index, as: UInt.self) { w[$0] }
            }
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
            return AnyInt(inline: result)
        case .buffer(let buffer):
            let result = AnyIntBuffer.create(bits: x.bitWidth)
            result.withPointerToElements { elements in
                buffer.withPointerToElements { sourceElements in
                    for i in 0..<elements.count {
                        elements[i] = ~sourceElements[i]
                    }
                }
            }
            return AnyInt(normalised: result)
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
            lhs = AnyInt(normalising: result)
        }
    }

    public static func >>= <RHS: BinaryInteger>(lhs: inout AnyInt, rhs: RHS) {
        lhs = lhs.shift(by: -Int(exactly: rhs)!)
    }

    public static func <<= <RHS: BinaryInteger>(lhs: inout AnyInt, rhs: RHS) {
        lhs = lhs.shift(by: +Int(exactly: rhs)!)
    }

    private func shift(by bits: Int) -> AnyInt {
        let bitWidth = self.bitWidth + bits
        if bitWidth <= 0 {
            return self.isNegative ? .minusOne : .zero
        }
        return self.storage.withWords { words in
            if bitWidth <= TinyWord.bitWidth {
                let tiny = TinyWord(bitPattern: words[bitOffset: -bits])!
                return AnyInt(inline: tiny)
            }

            let buffer = AnyIntBuffer.create(bits: bitWidth)
            buffer.withPointerToElements { elements in
                for i in 0..<elements.count {
                    elements[i] = words[bitOffset: i * UnsignedWord.bitWidth - bits]
                }
            }
            return AnyInt(normalised: buffer)
        }
    }

    public func dividing(_ dividend: AnyInt) -> (quotient: AnyInt, remainder: AnyInt) {
        precondition(!self.isZero)
        if case (.inline(let lhsTiny), .inline(let rhsTiny)) = (dividend.storage, self.storage) {
            let quotient = AnyInt(lhsTiny.rawValue / rhsTiny.rawValue)
            let remainder = TinyWord(rawValue: lhsTiny.rawValue % rhsTiny.rawValue)!
            return (quotient: quotient, remainder: AnyInt(inline: remainder))
        }
        let quotientBitWidth = Swift.max(1, dividend.bitWidth - self.bitWidth + 2)
        let quotient = AnyIntBuffer.create(bits: quotientBitWidth)

        let dividerMagnitude = self.magnitude

        let remainder = AnyIntBuffer.create(bits: dividend.bitWidth + (dividend.isNegative ? 1 : 0))
        remainder.withPointerToElements { remainderElements in
            dividend.storage.withWords { dividendWords in
                if dividendWords.isNegative {
                    var carry: Bool = true
                    for i in 0..<remainderElements.count {
                        let t = (~dividendWords[i]).addingReportingOverflow(carry ? 1 : 0)
                        remainderElements[i] = t.partialValue
                        carry = t.overflow
                    }
                } else {
                    for i in 0..<remainderElements.count {
                        remainderElements[i] = dividendWords[i]
                    }
                }
            }
            quotient.withPointerToElements { quotientElements in
                dividerMagnitude.storage.withWords { dividerWords in
                    let dividerHigh = dividerWords[bitOffset: dividerWords.unsignedBitWidth - UnsignedWord.bitWidth]
                    let dividerHighSecond = dividerWords[bitOffset: dividerWords.unsignedBitWidth - 2 * UnsignedWord.bitWidth]
                    for i in (0..<quotientElements.count).reversed() {
                        let remainderWords = WordsView(remainderElements)
                        let guessDividendHigh = remainderWords[bitOffset: dividerWords.unsignedBitWidth + UnsignedWord.bitWidth * i]
                        var qHat: UnsignedWord
                        if guessDividendHigh >= dividerHigh {
                            qHat = UnsignedWord.max
                        } else {
                            let guessDividendMid = remainderWords[bitOffset: dividerWords.unsignedBitWidth + UnsignedWord.bitWidth * (i - 1)]
                            let guessDividendLow = remainderWords[bitOffset: dividerWords.unsignedBitWidth + UnsignedWord.bitWidth * (i - 2)]

                            let guessDividend = (high: guessDividendHigh, low: guessDividendMid)
                            let t = dividerHigh.dividingFullWidth(guessDividend)
                            qHat = t.quotient
                            let rHat = t.remainder

                            // Check if guess needs to be adjusted based on next digits of the divider and dividend
                            var m = qHat.multipliedFullWidth(by: dividerHighSecond)
                            if isGreater(&m, high: rHat, low: guessDividendLow) {
                                qHat -= 1
                                if isGreater(&m, high: dividerHigh, low: dividerHighSecond) {
                                    qHat -= 1
                                }
                            }
                        }

                        // Unsigned multiplication
                        func subtractGuess() -> Bool {
                            if qHat == 0 { return false }

                            var borrowLo: UnsignedWord = 0
                            var borrowHi: UnsignedWord = 0
                            var k = i
                            for j in 0..<dividerWords.count {
                                do {
                                    let t = remainderElements[k].subtractingReportingOverflow(borrowLo)
                                    borrowHi += t.overflow ? 1 : 0
                                    remainderElements[k] = t.partialValue
                                }
                                let result = qHat.multipliedFullWidth(by: dividerWords[j])
                                do {
                                    let t = remainderElements[k].subtractingReportingOverflow(result.low)
                                    borrowHi += t.overflow ? 1 : 0
                                    remainderElements[k] = t.partialValue
                                }
                                do {
                                    let t = borrowHi.addingReportingOverflow(result.high)
                                    borrowLo = t.partialValue
                                    borrowHi = t.overflow ? 1 : 0
                                }
                                k += 1
                            }
                            assert(borrowHi == 0)
                            if k < remainderElements.count {
                                let t = remainderElements[k].subtractingReportingOverflow(borrowLo)
                                remainderElements[k] = t.partialValue
                                return t.overflow
                            } else {
                                return borrowLo > 0
                            }
                        }

                        if subtractGuess() {
                            qHat -= 1

                            var k = i
                            var carry: Bool = false
                            for j in 0..<dividerWords.count {
                                let t = add(remainderElements[k], dividerWords[j], carry: carry)
                                carry = t.carry
                                remainderElements[k] = t.partialValue
                                k += 1
                            }
                            assert(carry)
                            if k < remainderElements.count {
                                let t = remainderElements[k].addingReportingOverflow(carry ? 1 : 0)
                                remainderElements[k] = t.partialValue
                                carry = t.overflow
                            }
                            assert(carry)
                        }

                        quotientElements[i] = qHat
                    }
                }
                if self.isNegative != dividend.isNegative {
                    var carry: Bool = true
                    for i in 0..<quotientElements.count {
                        let t = (~quotientElements[i]).addingReportingOverflow(carry ? 1 : 0)
                        quotientElements[i] = t.partialValue
                        carry = t.overflow
                    }
                }
                if dividend.isNegative {
                    var carry: Bool = true
                    for i in 0..<remainderElements.count {
                        let t = (~remainderElements[i]).addingReportingOverflow(carry ? 1 : 0)
                        remainderElements[i] = t.partialValue
                        carry = t.overflow
                    }
                }
            }
        }
        return (quotient: AnyInt(normalising: quotient), remainder: AnyInt(normalising: remainder))
    }
}

private typealias DoubleWord = (high: UnsignedWord, low: UnsignedWord)
private func isGreater(_ lhs: inout DoubleWord, high: UnsignedWord, low: UnsignedWord) -> Bool {
    let low = subtract(lhs.low, low, borrow: false)
    lhs.low = low.partialValue
    let high = subtract(lhs.high, high, borrow: low.borrow)
    lhs.high = high.partialValue
    if high.borrow { return false }
    return lhs.low != 0 || lhs.high != 0
}
