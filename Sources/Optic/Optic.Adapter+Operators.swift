public import Either



public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Adapter<Never, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>.Adapter<Never, Never> {
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<Never, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<Never, NextBackwardFailure>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    BackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Adapter<Never, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<Never, BackwardFailure>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    BackwardFailure: Swift.Error,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<Never, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<Never, Either<BackwardFailure, NextBackwardFailure>>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    NextForwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<NextForwardFailure, Never>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    NextForwardFailure: Swift.Error,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<NextForwardFailure, NextBackwardFailure>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    BackwardFailure: Swift.Error,
    NextForwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<NextForwardFailure, BackwardFailure>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    BackwardFailure: Swift.Error,
    NextForwardFailure: Swift.Error,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<Never, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<
        NextForwardFailure,
        Either<BackwardFailure, NextBackwardFailure>
    >
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<ForwardFailure, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Adapter<Never, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<ForwardFailure, Never>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<ForwardFailure, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<Never, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<ForwardFailure, NextBackwardFailure>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    BackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>
        .Adapter<ForwardFailure, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Adapter<Never, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<ForwardFailure, BackwardFailure>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    BackwardFailure: Swift.Error,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>
        .Adapter<ForwardFailure, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<Never, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<
        ForwardFailure,
        Either<BackwardFailure, NextBackwardFailure>
    >
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    NextForwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<ForwardFailure, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<Either<ForwardFailure, NextForwardFailure>, Never>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    NextForwardFailure: Swift.Error,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Adapter<ForwardFailure, Never>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<
        Either<ForwardFailure, NextForwardFailure>,
        NextBackwardFailure
    >
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    BackwardFailure: Swift.Error,
    NextForwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>
        .Adapter<ForwardFailure, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, Never>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<
        Either<ForwardFailure, NextForwardFailure>,
        BackwardFailure
    >
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    BackwardFailure: Swift.Error,
    NextForwardFailure: Swift.Error,
    NextBackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>
        .Adapter<ForwardFailure, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, NextBackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<
        Either<ForwardFailure, NextForwardFailure>,
        Either<BackwardFailure, NextBackwardFailure>
    >
{
    lhs.appending(rhs)
}



public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    BackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Isomorphism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>
        .Adapter<ForwardFailure, BackwardFailure>
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<ForwardFailure, BackwardFailure>
{
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable,
    ForwardFailure: Swift.Error,
    BackwardFailure: Swift.Error
>(
    lhs: Optic<Source, Target, Focus, Replacement>
        .Adapter<ForwardFailure, BackwardFailure>,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
) -> Optic<Source, Target, NextFocus, NextReplacement>
    .Adapter<ForwardFailure, BackwardFailure>
{
    lhs.appending(rhs)
}
