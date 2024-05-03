#if MICRO_WORD
@inline(__always)
func resizedWord<
    Src: FixedWidthInteger & UnsignedInteger,
    Dst: FixedWidthInteger & UnsignedInteger
>(index: Int, as type: Dst.Type, from source: (Int) -> Src) -> Dst {
    if Dst.bitWidth == Src.bitWidth {
        return Dst(source(index))
    }
    else if Dst.bitWidth < Src.bitWidth {
        assert(Src.bitWidth % Dst.bitWidth == 0)
        let srcPerDst = (Src.bitWidth / Dst.bitWidth)
        let srcWord = source(index / srcPerDst)
        let shift = (index % srcPerDst) * Dst.bitWidth
        return Dst(truncatingIfNeeded: srcWord >> shift)
    } else {
        assert(Dst.bitWidth % Src.bitWidth == 0)
        let dstPerSrc = (Dst.bitWidth / Src.bitWidth)
        var result: Dst = 0
        for i in 0..<dstPerSrc {
            let srcWord = source(index * dstPerSrc + i)
            result |= Dst(srcWord) << (Src.bitWidth * i)
        }
        return result
    }
}
#else
@inline(__always)
func resizedWord(index: Int, as type: UnsignedWord.Type, from source: (Int) -> UnsignedWord) -> UnsignedWord {
    return source(index)
}
#endif
