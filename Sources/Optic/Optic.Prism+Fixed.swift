import Either

extension Optic.Prism
where
    Source == Target,
    Source: Copyable & Escapable & Equatable,
    Focus == Void,
    Replacement == Void
{
    public static func fixed(_ value: Source) -> Self {
        .init(
            match: { source in
                source == value ? .right(()) : .left(source)
            },
            embed: { _ in value }
        )
    }
}
