extension Swift::String {
    public struct Isomorphisms: Sendable {
        public init() {}
    }

    public static var isomorphisms: Isomorphisms { .init() }
}

extension Swift::String.Isomorphisms {
    public var substring:
        Optic<
            Substring,
            Substring,
            String,
            String
        >.Isomorphism
    {
        .init(
            forward: { String($0) },
            backward: { Substring($0) }
        )
    }
}
