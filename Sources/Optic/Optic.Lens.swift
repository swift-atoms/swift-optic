extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public struct Lens: Sendable {
        public var decompose: @Sendable (consuming Source) -> (
            focus: Focus,
            reconstruct: @Sendable (consuming Replacement) -> Target
        )

        public init(
            decompose: @escaping @Sendable (consuming Source) -> (
                focus: Focus,
                reconstruct: @Sendable (consuming Replacement) -> Target
            )
        ) {
            self.decompose = decompose
        }
    }
}

extension Optic.Lens
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public func get(_ source: consuming Source) -> Focus {
        decompose(source).focus
    }

    public func set(
        _ source: consuming Source,
        _ replacement: consuming Replacement
    ) -> Target {
        decompose(source).reconstruct(replacement)
    }
}

extension Optic.Lens
where
    Source == Target,
    Source: Copyable & Escapable & Sendable,
    Focus == Replacement
{
    public init(
        get: @escaping @Sendable (Source) -> Focus,
        set: @escaping @Sendable (Source, Replacement) -> Target
    ) {
        self.init { source in
            (
                focus: get(source),
                reconstruct: { replacement in set(source, replacement) }
            )
        }
    }
}
