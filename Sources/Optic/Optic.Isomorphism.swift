extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public struct Isomorphism: Sendable {
        public var forward: @Sendable (consuming Source) -> Focus
        public var backward: @Sendable (consuming Replacement) -> Target

        /// Creates a total, law-claiming bidirectional transformation.
        ///
        /// - Law: For a monomorphic specialization, `backward(forward(source))`
        ///   equals `source` and `forward(backward(focus))` equals `focus`.
        /// - Law: A polymorphic specialization belongs to a coherent
        ///   type-changing family whose monomorphic members obey those inverse
        ///   equations.
        public init(
            forward: @escaping @Sendable (consuming Source) -> Focus,
            backward: @escaping @Sendable (consuming Replacement) -> Target
        ) {
            self.forward = forward
            self.backward = backward
        }
    }
}
