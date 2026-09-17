extension Optic
where Source: Copyable & Escapable, Target: Copyable & Escapable,
    Focus: Copyable & Escapable, Replacement: Copyable & Escapable
{
    /// A lens whose accessors can safely be captured by a sendable transition.
    /// Construct it from sendable closures; a local Lens is not implicitly promoted.
    public struct SendableLens: Swift.Sendable {
        public let get: @Sendable (Source) -> Focus
        public let set: @Sendable (Source, Replacement) -> Target

        public init(
            get: @escaping @Sendable (Source) -> Focus,
            set: @escaping @Sendable (Source, Replacement) -> Target
        ) {
            self.get = get
            self.set = set
        }
    }
}
