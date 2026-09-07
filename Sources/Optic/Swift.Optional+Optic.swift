import Either

extension Swift.Optional: __OpticPrismAccessible where Wrapped: Copyable & Escapable {
    @dynamicMemberLookup
    public struct Prisms {
        public init() {}
    }

    public static var prisms: Prisms { .init() }
}
