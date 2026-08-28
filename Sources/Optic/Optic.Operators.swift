precedencegroup OpticCompositionPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

infix operator >>> : OpticCompositionPrecedence

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Isomorphism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Isomorphism {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Isomorphism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
) -> Optic<Source, Target, NextFocus, NextReplacement>.Lens {
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Isomorphism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Prism {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Isomorphism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine
) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Lens,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
) -> Optic<Source, Target, NextFocus, NextReplacement>.Lens {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Lens,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Lens {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Lens,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Prism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Prism {
    lhs.appending(rhs)
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable,
    NextFocus: ~Copyable & Escapable,
    NextReplacement: ~Copyable & ~Escapable
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Prism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Prism {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Prism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Affine,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine
) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Affine,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Affine,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Affine,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus: Sendable, Replacement, NextFocus: Sendable, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Traversal,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Traversal
) -> Optic<Source, Target, NextFocus, NextReplacement>.Traversal {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Setter,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Isomorphism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Lens,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Prism,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Affine,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Traversal,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(rhs)
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Setter,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter(rhs))
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Setter,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter(rhs))
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Setter,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter(rhs))
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Setter,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter(rhs))
}

public func >>> <Source, Target, Focus, Replacement, NextFocus, NextReplacement>(
    lhs: Optic<Source, Target, Focus, Replacement>.Setter,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Traversal
) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
    lhs.appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter(rhs))
}
