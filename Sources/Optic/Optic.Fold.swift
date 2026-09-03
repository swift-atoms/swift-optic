import Either

extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & ~Escapable,
    Focus: ~Copyable & ~Escapable,
    Replacement: ~Copyable & ~Escapable
{
    /// A borrowed, read-only optic onto zero or one focus.
    ///
    /// `Fold` is the read-only weakening of `Prism` and `Affine`: it never
    /// reconstructs a target, so it only ever borrows its source and lends the
    /// focus to a visitor. `Target` and `Replacement` are carried for
    /// composition with the reconstructing optics and are otherwise inert.
    ///
    /// - Law: A fold obtained from a prism visits a focus exactly when the
    ///   prism's match returns `Either.right`, and lends that same focus.
    public struct Fold {
        public var visit: (borrowing Source, (borrowing Focus) -> Void) -> Bool

        public init(
            visit: @escaping (borrowing Source, (borrowing Focus) -> Void) -> Bool
        ) {
            self.visit = visit
        }
    }
}

extension Optic.Fold
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & ~Escapable,
    Focus: ~Copyable & ~Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public func callAsFunction(
        _ source: borrowing Source,
        _ body: (borrowing Focus) -> Void
    ) -> Bool {
        visit(source, body)
    }

    public func matches(_ source: borrowing Source) -> Bool {
        visit(source) { _ in }
    }
}

extension Optic.Fold
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & ~Escapable,
    Focus: Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public func extract(_ source: borrowing Source) -> Focus? {
        var extracted: Focus? = nil
        _ = visit(source) { focus in extracted = copy focus }
        return extracted
    }
}

extension Optic.Fold
where
    Source: Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    /// Weakens a prism to a fold by matching a copy of the borrowed source.
    public init(_ prism: Optic<Source, Target, Focus, Replacement>.Prism) {
        self.init { source, body in
            let result = prism.match(copy source)
            switch consume result {
            case .left:
                return false
            case let .right(focus):
                body(focus)
                return true
            }
        }
    }

    /// Weakens an affine traversal to a fold by decomposing a copy of the
    /// borrowed source.
    public init(_ affine: Optic<Source, Target, Focus, Replacement>.Affine) {
        self.init { source, body in
            let decomposition = affine.decompose(copy source)
            switch consume decomposition {
            case .left:
                return false
            case let .right((focus, _)):
                body(focus)
                return true
            }
        }
    }

    /// Weakens a lens to a fold that always visits.
    public init(_ lens: Optic<Source, Target, Focus, Replacement>.Lens) {
        self.init { source, body in
            body(lens.get(copy source))
            return true
        }
    }
}

extension Optic.Fold
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & ~Escapable,
    Focus: ~Copyable & ~Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public static func composing<
        NextFocus: ~Copyable & ~Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ first: Self,
        _ second: Optic<Focus, Replacement, NextFocus, NextReplacement>.Fold
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Fold {
        .init { source, body in
            var visited = false
            _ = first.visit(source) { focus in
                visited = second.visit(focus, body)
            }
            return visited
        }
    }

    public func appending<
        NextFocus: ~Copyable & ~Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Fold
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Fold {
        Self.composing(self, next)
    }
}

extension Optic.Fold
where
    Source == Target,
    Target == Focus,
    Focus == Replacement,
    Source: ~Copyable & ~Escapable
{
    public static var identity: Self {
        .init { source, body in
            body(source)
            return true
        }
    }
}

public func >>> <
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & ~Escapable,
    Focus: ~Copyable & ~Escapable,
    Replacement: ~Copyable & ~Escapable,
    NextFocus: ~Copyable & ~Escapable,
    NextReplacement: ~Copyable & ~Escapable
>(
    lhs: Optic<Source, Target, Focus, Replacement>.Fold,
    rhs: Optic<Focus, Replacement, NextFocus, NextReplacement>.Fold
) -> Optic<Source, Target, NextFocus, NextReplacement>.Fold {
    lhs.appending(rhs)
}
