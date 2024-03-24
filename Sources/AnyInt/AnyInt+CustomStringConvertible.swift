extension AnyInt: CustomStringConvertible {
    public var description: String {
        return String(self, radix: 10)
    }
}
