public import Either

private func composeTotal<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable
>(
    _ first: @escaping (consuming Input) -> Intermediate,
    _ second: @escaping (consuming Intermediate) -> Output
) -> (consuming Input) -> Output {
    { second(first($0)) }
}

private func composeFirstFailure<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable,
    Failure: Swift.Error
>(
    _ first: @escaping
        (consuming Input) throws(Failure) -> Intermediate,
    _ second: @escaping (consuming Intermediate) -> Output
) -> (consuming Input) throws(Failure) -> Output {
    { second(try first($0)) }
}

private func composeSecondFailure<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable,
    Failure: Swift.Error
>(
    _ first: @escaping (consuming Input) -> Intermediate,
    _ second: @escaping
        (consuming Intermediate) throws(Failure) -> Output
) -> (consuming Input) throws(Failure) -> Output {
    { try second(first($0)) }
}

private func composeFailures<
    Input: ~Copyable & ~Escapable,
    Intermediate: ~Copyable & Escapable,
    Output: ~Copyable & Escapable,
    FirstFailure: Swift.Error,
    SecondFailure: Swift.Error
>(
    _ first: @escaping
        (consuming Input) throws(FirstFailure) -> Intermediate,
    _ second: @escaping
        (consuming Intermediate) throws(SecondFailure) -> Output
) ->
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
    _ first: @escaping
        (consuming Intermediate) throws(FirstFailure) -> Output,
    _ second: @escaping
        (consuming Input) throws(SecondFailure) -> Intermediate
) ->
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
