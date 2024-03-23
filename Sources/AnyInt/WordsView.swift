struct WordsView {
    var start: UnsafePointer<UnsignedWord>
    var count: Int

    var isNegative: Bool {
        return signWord < 0
    }

    var bitWidth: Int {
        return (count - 1) * UnsignedWord.bitWidth + signWord.usedBits
    }

    var signWord: SignedWord {
        return SignedWord(bitPattern: start[count - 1])
    }

    subscript(_ index: Int) -> UnsignedWord {
        if index < count {
            return start[index]
        } else {
            return isNegative ? .max : 0
        }
    }
}
