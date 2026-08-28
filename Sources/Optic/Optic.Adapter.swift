extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    /// Two unrestricted directional transformations.
    ///
    /// `Adapter` makes no round-trip or coherence claim. Its directions may be
    /// independently partial, lossy, validating, or otherwise unrelated.
    public struct Adapter<
        ForwardFailure: Swift.Error,
        BackwardFailure: Swift.Error
    >: Sendable {
        public var forward:
            @Sendable (consuming Source) throws(ForwardFailure) -> Focus
        public var backward:
            @Sendable (consuming Replacement) throws(BackwardFailure) -> Target

        public init(
            forward: @escaping @Sendable
                (consuming Source) throws(ForwardFailure) -> Focus,
            backward: @escaping @Sendable
                (consuming Replacement) throws(BackwardFailure) -> Target
        ) {
            self.forward = forward
            self.backward = backward
        }
    }
}
