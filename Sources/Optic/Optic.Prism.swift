public import Either

extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    @dynamicMemberLookup
    public struct Prism {
        public var match: (consuming Source) -> Either<Target, Focus>
        public var embed: (consuming Replacement) -> Target

        /// Creates a total, law-claiming structural match and embedding.
        ///
        /// Structural mismatch is represented by `Either.left` so the consumed
        /// source remains available as a reconstructed target.
        ///
        /// - Law: For a monomorphic specialization, matching an embedded focus
        ///   returns that focus in `Either.right`.
        /// - Law: Matching a source either returns that same source in
        ///   `Either.left`, or returns a focus that embeds back to that source.
        public init(
            match: @escaping (consuming Source) -> Either<Target, Focus>,
            embed: @escaping (consuming Replacement) -> Target
        ) {
            self.match = match
            self.embed = embed
        }
    }
}

extension Optic.Prism
where
    Source == Target,
    Source: Copyable & Escapable,
    Focus == Replacement
{
    public init(
        embed: @escaping (Replacement) -> Target,
        extract: @escaping (Source) -> Focus?
    ) {
        self.init(
            match: { source in
                if let focus = extract(source) {
                    return .right(focus)
                }
                return .left(source)
            },
            embed: embed
        )
    }
}
