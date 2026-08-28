import Either

extension Optic.Prism
where
    Source == Target,
    Source: Copyable & Escapable & Equatable & Sendable,
    Focus == Void,
    Replacement == Void
{
    /// Matches one fixed value and preserves any mismatch.
    ///
    /// - Law: Embedding `Void` produces `value`; matching `value` succeeds,
    ///   while every other source is returned unchanged in `Either.left`.
    public static func fixed(_ value: Source) -> Self {
        .init(
            match: { source in
                source == value ? .right(()) : .left(source)
            },
            embed: { _ in value }
        )
    }
}
