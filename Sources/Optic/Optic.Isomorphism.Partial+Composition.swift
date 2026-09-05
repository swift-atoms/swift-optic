public import Either

extension Optic.Isomorphism.Partial
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{
    /// Composition of two total correspondences remains total.
    public func appending<
        NextFocus: ~Copyable & Escapable
    >(
        _ next: Optic<Focus, Focus, NextFocus, NextFocus>
            .Isomorphism.Partial<Never, Never>
    ) -> Optic<Source, Source, NextFocus, NextFocus>
        .Isomorphism.Partial<Never, Never>
    where ForwardFailure == Never, BackwardFailure == Never {
        .init(adapter: adapter.appending(next.adapter))
    }

    /// A total first correspondence introduces no additional failures.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextForwardFailure: Swift.Error,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Focus, NextFocus, NextFocus>
            .Isomorphism.Partial<NextForwardFailure, NextBackwardFailure>
    ) -> Optic<Source, Source, NextFocus, NextFocus>
        .Isomorphism.Partial<NextForwardFailure, NextBackwardFailure>
    where ForwardFailure == Never, BackwardFailure == Never {
        .init(adapter: adapter.appending(next.adapter))
    }

    /// A total second correspondence introduces no additional failures.
    public func appending<
        NextFocus: ~Copyable & Escapable
    >(
        _ next: Optic<Focus, Focus, NextFocus, NextFocus>
            .Isomorphism.Partial<Never, Never>
    ) -> Optic<Source, Source, NextFocus, NextFocus>
        .Isomorphism.Partial<ForwardFailure, BackwardFailure> {
        .init(adapter: adapter.appending(next.adapter))
    }

    /// Composes supported domains and preserves the origin of each failure.
    ///
    /// A `.left` failure comes from this correspondence and a `.right` failure
    /// from `next`, in either direction. If either correspondence is total,
    /// the more specific overload preserves the other correspondence's errors.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextForwardFailure: Swift.Error,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Focus, NextFocus, NextFocus>
            .Isomorphism.Partial<NextForwardFailure, NextBackwardFailure>
    ) -> Optic<Source, Source, NextFocus, NextFocus>
        .Isomorphism.Partial<
            Either<ForwardFailure, NextForwardFailure>,
            Either<BackwardFailure, NextBackwardFailure>
        > {
        .init(adapter: adapter.appending(next.adapter))
    }
}

extension Optic.Isomorphism.Partial
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{
    public func appending<NextFocus: ~Copyable & Escapable>(
        _ next: Optic<Focus, Focus, NextFocus, NextFocus>.Isomorphism
    ) -> Optic<Source, Source, NextFocus, NextFocus>
        .Isomorphism.Partial<ForwardFailure, BackwardFailure>
    {
        appending(next.partial)
    }
}

extension Optic.Isomorphism
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{
    public func appending<
        NextFocus: ~Copyable & Escapable,
        ForwardFailure: Swift.Error,
        BackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Focus, NextFocus, NextFocus>
            .Isomorphism.Partial<ForwardFailure, BackwardFailure>
    ) -> Optic<Source, Source, NextFocus, NextFocus>
        .Isomorphism.Partial<ForwardFailure, BackwardFailure>
    {
        partial.appending(next)
    }
}
