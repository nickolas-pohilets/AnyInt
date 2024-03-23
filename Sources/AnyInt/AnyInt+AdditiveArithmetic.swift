extension AnyInt: AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        return addOrSubstract(
            lhs: lhs,
            rhs: rhs,
            tinyOp: (+),
            wordOp: { a, b, carry in
                let tmp1 = a.addingReportingOverflow(b)
                let tmp2 = tmp1.partialValue.addingReportingOverflow(carry ? 1 : 0)
                return (tmp2.partialValue, tmp1.overflow || tmp2.overflow)
            }
        )
    }

    public static func - (lhs: AnyInt, rhs: AnyInt) -> AnyInt {
        return addOrSubstract(
            lhs: lhs,
            rhs: rhs,
            tinyOp: (-),
            wordOp: { a, b, carry in
                let tmp1 = a.subtractingReportingOverflow(b)
                let tmp2 = tmp1.partialValue.subtractingReportingOverflow(carry ? 1 : 0)
                return (tmp2.partialValue, tmp1.overflow || tmp2.overflow)
            }
        )
    }

    @inline(__always)
    private static func addOrSubstract(
        lhs: Self, rhs: Self,
        tinyOp: (SignedWord, SignedWord) -> SignedWord,
        wordOp: (UnsignedWord, UnsignedWord, Bool) -> (UnsignedWord, Bool)
    ) -> Self {
        if case (.inline(let lhsTiny), .inline(let rhsTiny)) = (lhs.storage, rhs.storage) {
            // Can overflow 63 bits, but not 64 bits
            let result = tinyOp(lhsTiny.rawValue, rhsTiny.rawValue)
            return Self(result)
        }
        return lhs.storage.withWords { lhsView in
            return rhs.storage.withWords { rhsView in
                let bits = max(lhsView.bitWidth, rhsView.bitWidth) + (lhsView.isNegative == rhsView.isNegative ? 1 : 0)
                let resultBuffer = AnyIntBuffer.create(bits: bits)
                resultBuffer.withPointerToElements { result in
                    var carry: Bool = false
                    for i in 0..<result.count {
                        let r = wordOp(lhsView[i], rhsView[i], carry)
                        result[i] = r.0
                        carry = r.1
                    }
                }
                if let tiny = resultBuffer.truncate() {
                    return Self(storage: .inline(tiny))
                } else {
                    return Self(storage: .buffer(resultBuffer))
                }
            }
        }
    }


}
