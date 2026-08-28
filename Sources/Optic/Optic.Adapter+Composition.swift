public import Either

private func composeTotal<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable
>(
    _ first: @escaping @Sendable (consuming Input) -> Intermediate,
    _ second: @escaping @Sendable (consuming Intermediate) -> Output
) -> @Sendable (consuming Input) -> Output {
    { second(first($0)) }
}

private func composeFirstFailure<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable,
    Failure: Swift.Error
>(
    _ first: @escaping @Sendable
        (consuming Input) throws(Failure) -> Intermediate,
    _ second: @escaping @Sendable (consuming Intermediate) -> Output
) -> @Sendable (consuming Input) throws(Failure) -> Output {
    { second(try first($0)) }
}

private func composeSecondFailure<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable,
    Failure: Swift.Error
>(
    _ first: @escaping @Sendable (consuming Input) -> Intermediate,
    _ second: @escaping @Sendable
        (consuming Intermediate) throws(Failure) -> Output
) -> @Sendable (consuming Input) throws(Failure) -> Output {
    { try second(first($0)) }
}

private func composeFailures<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable,
    FirstFailure: Swift.Error,
    SecondFailure: Swift.Error
>(
    _ first: @escaping @Sendable
        (consuming Input) throws(FirstFailure) -> Intermediate,
    _ second: @escaping @Sendable
        (consuming Intermediate) throws(SecondFailure) -> Output
) -> @Sendable
    (consuming Input) throws(Either<FirstFailure, SecondFailure>) -> Output
{
    { input in
        let intermediate: Intermediate
        do throws(FirstFailure) {
            intermediate = try first(input)
        } catch {
            throw .left(error)
        }
        do throws(SecondFailure) {
            return try second(intermediate)
        } catch {
            throw .right(error)
        }
    }
}

private func composeBackwardFailures<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable,
    FirstFailure: Swift.Error,
    SecondFailure: Swift.Error
>(
    _ first: @escaping @Sendable
        (consuming Intermediate) throws(FirstFailure) -> Output,
    _ second: @escaping @Sendable
        (consuming Input) throws(SecondFailure) -> Intermediate
) -> @Sendable
    (consuming Input) throws(Either<FirstFailure, SecondFailure>) -> Output
{
    { input in
        let intermediate: Intermediate
        do throws(SecondFailure) {
            intermediate = try second(input)
        } catch {
            throw .right(error)
        }
        do throws(FirstFailure) {
            return try first(intermediate)
        } catch {
            throw .left(error)
        }
    }
}

extension Optic.Adapter
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable
{
    // Forward: Never + Never. Backward: Never + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<Never, Never>
    where ForwardFailure == Never, BackwardFailure == Never {
        .init(
            forward: composeTotal(forward, next.forward),
            backward: composeTotal(next.backward, backward)
        )
    }

    // Forward: Never + Never. Backward: Never + E.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<Never, NextBackwardFailure>
    where ForwardFailure == Never, BackwardFailure == Never {
        .init(
            forward: composeTotal(forward, next.forward),
            backward: composeFirstFailure(next.backward, backward)
        )
    }

    // Forward: Never + Never. Backward: E + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<Never, BackwardFailure>
    where ForwardFailure == Never {
        .init(
            forward: composeTotal(forward, next.forward),
            backward: composeSecondFailure(next.backward, backward)
        )
    }

    // Forward: Never + Never. Backward: E1 + E2.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<Never, Either<BackwardFailure, NextBackwardFailure>>
    where ForwardFailure == Never {
        .init(
            forward: composeTotal(forward, next.forward),
            backward: composeBackwardFailures(backward, next.backward)
        )
    }

    // Forward: Never + E. Backward: Never + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, Never>
    where ForwardFailure == Never, BackwardFailure == Never {
        .init(
            forward: composeSecondFailure(forward, next.forward),
            backward: composeTotal(next.backward, backward)
        )
    }

    // Forward: Never + E. Backward: Never + E.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, NextBackwardFailure>
    where ForwardFailure == Never, BackwardFailure == Never {
        .init(
            forward: composeSecondFailure(forward, next.forward),
            backward: composeFirstFailure(next.backward, backward)
        )
    }

    // Forward: Never + E. Backward: E + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<NextForwardFailure, BackwardFailure>
    where ForwardFailure == Never {
        .init(
            forward: composeSecondFailure(forward, next.forward),
            backward: composeSecondFailure(next.backward, backward)
        )
    }

    // Forward: Never + E. Backward: E1 + E2.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<
            NextForwardFailure,
            Either<BackwardFailure, NextBackwardFailure>
        >
    where ForwardFailure == Never {
        .init(
            forward: composeSecondFailure(forward, next.forward),
            backward: composeBackwardFailures(backward, next.backward)
        )
    }

    // Forward: E + Never. Backward: Never + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<ForwardFailure, Never>
    where BackwardFailure == Never {
        .init(
            forward: composeFirstFailure(forward, next.forward),
            backward: composeTotal(next.backward, backward)
        )
    }

    // Forward: E + Never. Backward: Never + E.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<ForwardFailure, NextBackwardFailure>
    where BackwardFailure == Never {
        .init(
            forward: composeFirstFailure(forward, next.forward),
            backward: composeFirstFailure(next.backward, backward)
        )
    }

    // Forward: E + Never. Backward: E + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<ForwardFailure, BackwardFailure> {
        .init(
            forward: composeFirstFailure(forward, next.forward),
            backward: composeSecondFailure(next.backward, backward)
        )
    }

    // Forward: E + Never. Backward: E1 + E2.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<Never, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<
            ForwardFailure,
            Either<BackwardFailure, NextBackwardFailure>
        > {
        .init(
            forward: composeFirstFailure(forward, next.forward),
            backward: composeBackwardFailures(backward, next.backward)
        )
    }

    // Forward: E1 + E2. Backward: Never + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<Either<ForwardFailure, NextForwardFailure>, Never>
    where BackwardFailure == Never {
        .init(
            forward: composeFailures(forward, next.forward),
            backward: composeTotal(next.backward, backward)
        )
    }

    // Forward: E1 + E2. Backward: Never + E.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<
            Either<ForwardFailure, NextForwardFailure>,
            NextBackwardFailure
        >
    where BackwardFailure == Never {
        .init(
            forward: composeFailures(forward, next.forward),
            backward: composeFirstFailure(next.backward, backward)
        )
    }

    // Forward: E1 + E2. Backward: E + Never.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, Never>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<
            Either<ForwardFailure, NextForwardFailure>,
            BackwardFailure
        > {
        .init(
            forward: composeFailures(forward, next.forward),
            backward: composeSecondFailure(next.backward, backward)
        )
    }

    // Forward: E1 + E2. Backward: E1 + E2.
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        NextForwardFailure: Swift.Error,
        NextBackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<NextForwardFailure, NextBackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<
            Either<ForwardFailure, NextForwardFailure>,
            Either<BackwardFailure, NextBackwardFailure>
        > {
        .init(
            forward: composeFailures(forward, next.forward),
            backward: composeBackwardFailures(backward, next.backward)
        )
    }
}

extension Optic.Isomorphism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    /// Losslessly weakens this law-claiming isomorphism to a lawless Adapter.
    public var adapter: Optic<Source, Target, Focus, Replacement>
        .Adapter<Never, Never>
    {
        .init(forward: forward, backward: backward)
    }
}

extension Optic.Isomorphism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable
{
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable,
        ForwardFailure: Swift.Error,
        BackwardFailure: Swift.Error
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Adapter<ForwardFailure, BackwardFailure>
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<ForwardFailure, BackwardFailure>
    {
        adapter.appending(next)
    }
}

extension Optic.Adapter
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable
{
    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>
            .Isomorphism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>
        .Adapter<ForwardFailure, BackwardFailure>
    {
        appending(next.adapter)
    }
}
