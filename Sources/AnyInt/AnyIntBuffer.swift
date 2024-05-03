struct AnyIntBufferHeader {
    var count: Int
}

final class AnyIntBuffer: ManagedBuffer<AnyIntBufferHeader, UnsignedWord>, Hashable, CustomReflectable {
    var customMirror: Mirror {
        withWords { words in
            Mirror(
                self,
                unlabeledChildren: (0..<words.count).map { words[$0] },
                displayStyle: .collection
            )
        }
    }

    static func create(bits: Int) -> AnyIntBuffer {
        precondition(bits > 0)
        let words = (bits + UnsignedWord.bitWidth - 1) / UnsignedWord.bitWidth
        let buffer = AnyIntBuffer.create(minimumCapacity: words) { _ in
            AnyIntBufferHeader(count: words)
        }
        return unsafeDowncast(buffer, to: AnyIntBuffer.self)
    }

    static func create(value: SignedWord) -> AnyIntBuffer {
        let result = create(bits: UnsignedWord.bitWidth)
        result.withUnsafeMutablePointerToElements { ptr in
            ptr.pointee = UnsignedWord(bitPattern: value)
        }
        return result
    }

    var count: Int { header.count }

    func withWords<R>(_ body: (WordsView) throws -> R) rethrows -> R {
        try self.withUnsafeMutablePointers { (header, elements) in
            let view = WordsView(start: elements, count: header.pointee.count)
            return try body(view)
        }
    }

    func withPointerToElements<R>(_ body: (UnsafeMutableBufferPointer<UnsignedWord>) throws -> R) rethrows -> R {
        try self.withUnsafeMutablePointers { (header, elements) in
            let buffer = UnsafeMutableBufferPointer(start: elements, count: header.pointee.count)
            return try body(buffer)
        }
    }

    static func == (lhs: AnyIntBuffer, rhs: AnyIntBuffer) -> Bool {
        if lhs === rhs { return true }
        if lhs.count != rhs.count { return false }
        return lhs.withPointerToElements { lhsElements in
            rhs.withPointerToElements { rhsElements in
                lhsElements.elementsEqual(rhsElements) { lhsElement, rhsElement in
                    lhsElement == rhsElement
                }
            }
        }
    }

    func hash(into hasher: inout Hasher) {
        withPointerToElements { buffer in
            hasher.combine(buffer.count)
            for element in buffer {
                hasher.combine(element)
            }
        }
    }

    var isNegative: Bool {
        withWords { words in
            words.isNegative
        }
    }

    var bitWidth: Int {
        withWords { words in
            words.bitWidth
        }
    }

    func truncate() -> TinyWord? {
        let isNegative = self.isNegative
        let filling: UnsignedWord = isNegative ? .max : 0
        return self.withUnsafeMutablePointers { (header, elements) in
            var k = header.pointee.count
            while k > 1 && elements[k - 1] == filling && isNegative == (SignedWord(bitPattern: elements[k - 2]) < 0) {
                k -= 1
            }
            header.pointee.count = k

            if k > 1 { return nil }
            return TinyWord(bitPattern: elements[0])
        }
    }
}
