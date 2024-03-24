extension AnyInt: Numeric {
    public typealias Magnitude = AnyInt

    public static func *= (lhs: inout AnyInt, rhs: AnyInt) {
        lhs = lhs * rhs
    }
    
    public init<T: BinaryInteger>(exactly source: T) {
        self.storage = .create(words: source.words, isSigned: T.isSigned)
    }
    
    public var magnitude: AnyInt {
        if self.isNegative {
            return -self
        } else {
            return self
        }
    }
    
    public static func * (lhs: AnyInt, rhs: AnyInt) -> AnyInt {
        if case (.inline(let lhsTiny), .inline(let rhsTiny)) = (lhs.storage, rhs.storage) {
            let result = lhsTiny.rawValue.multipliedFullWidth(by: rhsTiny.rawValue)
            let lowSigned = SignedWord(bitPattern: result.low)
            if result.high == 0 && lowSigned >= 0 {
                return Self(lowSigned)
            }
            if result.high == -1 && lowSigned < 0 {
                return Self(lowSigned)
            }
            let buffer = AnyIntBuffer.create(bits: 2 * UnsignedWord.bitWidth)
            buffer.withPointerToElements { elements in
                elements[0] = result.low
                elements[1] = UnsignedWord(bitPattern: result.high)
            }
            return Self(storage: .buffer(buffer))
        }

        // Check zero separately, because that's the only way result can be smaller then any of the arguments
        if lhs.isZero || rhs.isZero {
            return .zero
        }
        
        // X = abbb
        // Y = cddddddd
        //
        // X = a*-2^(m - 1) + bbb
        // Y = c*-2^(n - 1) + ddddddd
        //
        // X * Y = +ac * 2^(m + n - 2)
        //         -(a * ddddddd * 2^(m - 1))
        //         -(c * bbb * 2^(n - 1))
        //         bbb * ddddddd
        //
        //
        // Xu = a*2^(m - 1) + bbb
        // Yu = c*2^(n - 1) + ddddddd
        //
        // (X * Y) = Xu * Yu - (a * ddddddd * 2^m + c * bbb * 2^n)
        // (X * Y) = Xu * Yu - (a * Yu * 2^m + c * Xu * 2^n)
        //
        // X * Y = Z = efff_ffff_ffff
        //
        // = e * -2^(m*w + n*w - 1) + fff_ffff_ffff
        let bitWidth = lhs.bitWidth + rhs.bitWidth
        let buffer = AnyIntBuffer.create(bits: bitWidth)
        buffer.withPointerToElements { elements in
            lhs.storage.withWords { lhsWords in
                rhs.storage.withWords { rhsWords in
                    // Init to zero
                    for i in 0..<elements.count {
                        elements[i] = 0
                    }

                    // Unsigned multiplication
                    for i in 0..<lhsWords.count {
                        var carryLo: UnsignedWord = 0
                        var carryHi: UnsignedWord = 0
                        var k = i
                        for j in 0..<rhsWords.count {
                            do {
                                let t = elements[k].addingReportingOverflow(carryLo)
                                carryHi += t.overflow ? 1 : 0
                                elements[k] = t.partialValue
                            }
                            let result = lhsWords[i].multipliedFullWidth(by: rhsWords[j])
                            do {
                                let t = elements[k].addingReportingOverflow(result.low)
                                carryHi += t.overflow ? 1 : 0
                                elements[k] = t.partialValue
                            }
                            do {
                                let t = carryHi.addingReportingOverflow(result.high)
                                carryLo = t.partialValue
                                carryHi = t.overflow ? 1 : 0
                            }
                            k += 1
                        }
                        if k < elements.count {
                            elements[k] = elements[k] &+ carryLo
                        }
                    }

                    // Signed correction
                    if lhsWords.isNegative {
                        var borrow: Bool = false
                        for j in 0..<(elements.count - lhsWords.count) {
                            let t = subtract(elements[lhsWords.count + j], rhsWords[j], borrow: borrow)
                            elements[lhsWords.count + j] = t.word
                            borrow = t.borrow
                        }
                    }

                    if rhsWords.isNegative {
                        var borrow: Bool = false
                        for i in 0..<(elements.count - rhsWords.count) {
                            let t = subtract(elements[rhsWords.count + i], lhsWords[i], borrow: borrow)
                            elements[rhsWords.count + i] = t.word
                            borrow = t.borrow
                        }
                    }
                }
            }
        }
        return Self(storage: .buffer(buffer))
    }
}
