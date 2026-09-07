import Either

extension Swift.Result: __OpticPrismAccessible where Success: Copyable & Escapable {
    public struct Prisms {
        public init() {}
    }

    public static var prisms: Prisms { .init() }
}
