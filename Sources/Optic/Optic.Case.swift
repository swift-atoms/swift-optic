public import Either

extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{





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

    public init(_ prism: Optic<Source, Target, Focus, Replacement>.Prism) {
        self.init(prism: prism, fold: .init(prism))
    }
}
