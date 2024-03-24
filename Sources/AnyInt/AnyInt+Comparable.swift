extension AnyInt: Comparable {
    public static func == (lhs: AnyInt, rhs: AnyInt) -> Bool {
        return lhs.storage == rhs.storage
    }

    public static func < (lhs: AnyInt, rhs: AnyInt) -> Bool {
        if case (.inline(let lhsTiny), .inline(let rhsTiny)) = (lhs.storage, rhs.storage) {
            return lhsTiny.rawValue < rhsTiny.rawValue
        }
        // Compare signs and bit widths
        if lhs.isNegative {
            if rhs.isNegative {
                let lhsBitWidth = lhs.bitWidth
                let rhsBitWidth = rhs.bitWidth
                if lhsBitWidth > rhsBitWidth { return true }
                if lhsBitWidth < rhsBitWidth { return false }
            } else {
                return true
            }
        } else {
            if rhs.isNegative {
                return false
            } else {
                let lhsBitWidth = lhs.bitWidth
                let rhsBitWidth = rhs.bitWidth
                if lhsBitWidth < rhsBitWidth { return true }
                if lhsBitWidth > rhsBitWidth { return false }
            }
        }
        // Same sign, equal bit widths
        return lhs.storage.withWords { lhsView in
            return rhs.storage.withWords { rhsView in
                var borrow: Bool = false
                for i in 0..<lhsView.count {
                    borrow = subtract(lhsView[i], rhsView[i], borrow: borrow).borrow
                }
                return borrow
            }
        }
    }
}
