enum AnyIntStorage: Hashable {
    case inline(TinyWord)
    case buffer(AnyIntBuffer)

    var count: Int {
        switch self {
        case .inline: return 1
        case .buffer(let buffer): return buffer.count
        }
    }

    func withWords<R>(_ body: (WordsView) throws -> R) rethrows -> R {
        switch self {
        case .inline(let tiny):
            let value = tiny.bitPattern
            return try withUnsafePointer(to: value) { ptr in
                let view = WordsView(start: ptr, count: 1)
                return try body(view)
            }
        case .buffer(let buffer):
            return try buffer.withPointerToElements { buf in
                let view = WordsView(start: buf.baseAddress!, count: buf.count)
                return try body(view)
            }
        }
    }

    var isNegative: Bool {
        switch self {
        case .inline(let tiny):
            return tiny.isNegative
        case .buffer(let buffer):
            return buffer.isNegative
        }
    }

    var bitWidth: Int {
        switch self {
        case .inline(let tiny): return tiny.bitWidth
        case .buffer(let buffer): return buffer.bitWidth
        }
    }

    var inline: TinyWord? {
        switch self {
        case .inline(let tiny): return tiny
        case .buffer: return nil
        }
    }

    var buffer: AnyIntBuffer? {
        switch self {
        case .inline: return nil
        case .buffer(let buffer): return buffer
        }
    }
}
