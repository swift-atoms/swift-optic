extension Optic.Traversal
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    // Swift 6.4 Array still requires copyable elements.
    Focus: Copyable & Escapable,
    Replacement: Copyable & Escapable
{
    public struct Bazaar {
        public var focuses: [Focus]
        private var _reconstruct: (consuming [Replacement]) -> Target

        public init(
            focuses: consuming [Focus],
            reconstruct: @escaping (consuming [Replacement]) -> Target
        ) {
            self.focuses = focuses
            self._reconstruct = reconstruct
        }
    }
}

extension Optic.Traversal.Bazaar
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: Copyable & Escapable,
    Replacement: Copyable & Escapable
{
    public consuming func map(
        _ transform: (consuming Focus) -> Replacement
    ) -> Target {
        _reconstruct(focuses.map(transform))
    }

    public consuming func reconstruct(
        _ replacements: consuming [Replacement]
    ) -> Target {
        _reconstruct(replacements)
    }
}
