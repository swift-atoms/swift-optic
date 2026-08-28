public import Either

extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public struct Affine: Sendable {
        public var decompose: @Sendable (consuming Source) -> Either<
            Target,
            (
                focus: Focus,
                reconstruct: @Sendable (consuming Replacement) -> Target
            )
        >

        public init(
            decompose: @escaping @Sendable (consuming Source) -> Either<
                Target,
                (
                    focus: Focus,
                    reconstruct: @Sendable (consuming Replacement) -> Target
                )
            >
        ) {
            self.decompose = decompose
        }
    }
}

extension Optic.Affine
where
    Source == Target,
    Source: Copyable & Escapable & Sendable,
    Focus == Replacement
{
    public init(
        extract: @escaping @Sendable (Source) -> Focus?,
        set: @escaping @Sendable (Source, Replacement) -> Target
    ) {
        self.init { source in
            if let focus = extract(source) {
                return .right(
                    (
                        focus: focus,
                        reconstruct: { replacement in set(source, replacement) }
                    )
                )
            }
            return .left(source)
        }
    }
}

extension Optic.Affine
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    // `map` returns Replacement from its transform closure before passing it
    // to the stored reconstruction arrow. Swift 6.4 cannot express that
    // intermediate result lifetime for a nonescapable Replacement.
    Replacement: ~Copyable & Escapable
{
    public func map(
        _ source: consuming Source,
        _ transform: (consuming Focus) -> Replacement
    ) -> Target {
        let decomposition = decompose(source)
        switch consume decomposition {
        case let .left(target):
            return target
        case let .right((focus, reconstruct)):
            return reconstruct(transform(focus))
        }
    }

    public func set(
        _ source: consuming Source,
        _ replacement: Replacement
    ) -> Target
    where Replacement: Copyable {
        map(source) { _ in replacement }
    }
}

extension Optic.Traversal
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: Copyable & Escapable,
    Replacement: Copyable & Escapable
{
    /// Compatibility spelling for the affine optic that historically lived
    /// under the Array-backed total traversal namespace.
    public typealias Affine = Optic<
        Source,
        Target,
        Focus,
        Replacement
    >.Affine
}
