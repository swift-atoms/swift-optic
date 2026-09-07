public import Either

extension Optic.Isomorphism.Partial
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{

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


    public func appending<
        NextFocus: ~Copyable & Escapable
    >(
        _ next: Optic<Focus, Focus, NextFocus, NextFocus>
            .Isomorphism.Partial<Never, Never>
    ) -> Optic<Source, Source, NextFocus, NextFocus>
        .Isomorphism.Partial<ForwardFailure, BackwardFailure> {
        .init(adapter: adapter.appending(next.adapter))
    }






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
