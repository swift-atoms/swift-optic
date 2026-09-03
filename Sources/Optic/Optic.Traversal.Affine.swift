public import Either

extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public struct Affine {
        public var decompose: (consuming Source) -> Either<
            Target,
            (
                focus: Focus,
                reconstruct: (consuming Replacement) -> Target
            )
        >

        public init(
            decompose: @escaping (consuming Source) -> Either<
                Target,
                (
                    focus: Focus,
                    reconstruct: (consuming Replacement) -> Target
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
    Source: Copyable & Escapable,
    Focus == Replacement
{
    public init(
        extract: @escaping (Source) -> Focus?,
        set: @escaping (Source, Replacement) -> Target
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
