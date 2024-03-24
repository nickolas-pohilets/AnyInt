extension AnyInt: Strideable {
    public typealias Stride = Self

    public func distance(to other: AnyInt) -> AnyInt {
        return self - other
    }

    public func advanced(by n: AnyInt) -> AnyInt {
        return self + n
    }
}
