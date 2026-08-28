extension String {
    public struct Isomorphisms: Sendable {
        public init() {}

        /// Converts textual content between `Substring` and `String`.
        ///
        /// - Law: The two representations round-trip by textual value. This
        ///   isomorphism does not preserve backing storage or index provenance.
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
