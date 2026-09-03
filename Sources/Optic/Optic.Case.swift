public import Either

extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    /// One case of a coproduct: its prism, which consumes, beside its fold,
    /// which borrows.
    ///
    /// - Law: The fold visits a focus exactly when the prism's match returns
    ///   `Either.right`, and lends that same focus.
    public struct Case {
        public var prism: Optic<Source, Target, Focus, Replacement>.Prism
        public var fold: Optic<Source, Target, Focus, Replacement>.Fold

        public init(
            prism: Optic<Source, Target, Focus, Replacement>.Prism,
            fold: Optic<Source, Target, Focus, Replacement>.Fold
        ) {
            self.prism = prism
            self.fold = fold
        }
    }
}

extension Optic.Case
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public func match(_ source: consuming Source) -> Either<Target, Focus> {
        prism.match(source)
    }

    public func embed(_ replacement: consuming Replacement) -> Target {
        prism.embed(replacement)
    }

    public func visit(
        _ source: borrowing Source,
        _ body: (borrowing Focus) -> Void
    ) -> Bool {
        fold.visit(source, body)
    }

    public func matches(_ source: borrowing Source) -> Bool {
        fold.matches(source)
    }
}

extension Optic.Case
where
    Source: Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    /// A case over a copyable source, whose fold is the prism's own weakening.
    public init(_ prism: Optic<Source, Target, Focus, Replacement>.Prism) {
        self.init(prism: prism, fold: .init(prism))
    }
}
