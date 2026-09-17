extension Optic
where Source: Copyable & Escapable, Target == Source,
    Focus: Copyable & Escapable, Replacement == Focus
{
    /// A monomorphic prism with sendable extraction and embedding closures.
    public struct SendablePrism: Swift.Sendable {
        public let embed: @Sendable (Focus) -> Source
        public let extract: @Sendable (Source) -> Focus?

        public init(
            embed: @escaping @Sendable (Focus) -> Source,
            extract: @escaping @Sendable (Source) -> Focus?
        ) {
            self.embed = embed
            self.extract = extract
        }
    }
}
