extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    // The Array-backed total traversal fixes both element sorts to the
    // capabilities required by Swift 6.4's Array.
    Focus: Copyable & Escapable,
    Replacement: Copyable & Escapable
{
    public struct Traversal: Sendable {
        public var decompose: @Sendable (consuming Source) -> Bazaar

        public init(
            decompose: @escaping @Sendable (consuming Source) -> Bazaar
        ) {
            self.decompose = decompose
        }
    }
}

extension Optic.Traversal
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: Copyable & Escapable,
    Replacement: Copyable & Escapable
{
    public func map(
        _ source: consuming Source,
        _ transform: (consuming Focus) -> Replacement
    ) -> Target {
        decompose(source).map(transform)
    }
}
