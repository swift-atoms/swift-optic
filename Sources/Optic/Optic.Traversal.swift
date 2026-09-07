extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,


    Focus: Copyable & Escapable,
    Replacement: Copyable & Escapable
{
    public struct Traversal {
        public var decompose: (consuming Source) -> Bazaar

        public init(
            decompose: @escaping (consuming Source) -> Bazaar
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
