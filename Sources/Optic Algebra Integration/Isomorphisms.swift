public import Optic
public import Algebra
public import Bifunctor
public import Pair
public import Either

extension Optic.Isomorphism where Source: Copyable & Escapable, Target: Copyable & Escapable,
    Focus: Copyable & Escapable, Replacement: Copyable & Escapable,
    Source == Target, Focus == Replacement {
    public func transporting(_ monoid: Algebra::Algebra.Monoid<Focus>) -> Algebra::Algebra.Monoid<Source> {
        monoid.transported(to: { self.backward($0) }, from: { self.forward($0) })
    }
}

public enum AlgebraicIsomorphisms {
    public static func productAssociativity<A, B, C>() -> Optic<
        Pair<Pair<A, B>, C>, Pair<Pair<A, B>, C>, Pair<A, Pair<B, C>>, Pair<A, Pair<B, C>>
    >.Isomorphism {
        .init(forward: { Pair($0.first.first, Pair($0.first.second, $0.second)) },
            backward: { Pair(Pair($0.first, $0.second.first), $0.second.second) })
    }
    public static func leftUnit<A>() -> Optic<Pair<Void, A>, Pair<Void, A>, A, A>.Isomorphism {
        .init(forward: { $0.second }, backward: { Pair((), $0) })
    }
    public static func rightUnit<A>() -> Optic<Pair<A, Void>, Pair<A, Void>, A, A>.Isomorphism {
        .init(forward: { $0.first }, backward: { Pair($0, ()) })
    }
    public static func leftZero<A>() -> Optic<Either<Never, A>, Either<Never, A>, A, A>.Isomorphism {
        .init(forward: { $0.value }, backward: { .right($0) })
    }
    public static func rightZero<A>() -> Optic<Either<A, Never>, Either<A, Never>, A, A>.Isomorphism {
        .init(forward: { $0.value }, backward: { .left($0) })
    }
    public static func sumAssociativity<A, B, C>() -> Optic<
        Either<Either<A, B>, C>, Either<Either<A, B>, C>, Either<A, Either<B, C>>, Either<A, Either<B, C>>
    >.Isomorphism {
        .init(forward: { value in
            switch value {
            case .left(.left(let a)): return .left(a)
            case .left(.right(let b)): return .right(.left(b))
            case .right(let c): return .right(.right(c))
            }
        }, backward: { value in
            switch value {
            case .left(let a): return .left(.left(a))
            case .right(.left(let b)): return .left(.right(b))
            case .right(.right(let c)): return .right(c)
            }
        })
    }
    public static func distributivity<A, B, C>() -> Optic<
        Pair<A, Either<B, C>>, Pair<A, Either<B, C>>, Either<Pair<A, B>, Pair<A, C>>, Either<Pair<A, B>, Pair<A, C>>
    >.Isomorphism {
        .init(forward: { Bifunctor.Distributivity.distribute($0) },
            backward: { Bifunctor.Distributivity.factor($0) })
    }
}
