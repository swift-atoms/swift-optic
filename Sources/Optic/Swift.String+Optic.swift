extension Swift.String {
    public struct Isomorphisms: Sendable {
        public init() {}





        public var substring: Optic<
            Substring,
            Substring,
            String,
            String
        >.Isomorphism {
            .init(
                forward: { String($0) },
                backward: { Substring($0) }
            )
        }
    }

    public static var isomorphisms: Isomorphisms { .init() }
}
