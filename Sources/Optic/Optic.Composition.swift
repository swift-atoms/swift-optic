import Either

extension Optic.Isomorphism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public var reversed: Optic<Replacement, Focus, Target, Source>.Isomorphism {
        .init(forward: backward, backward: forward)
    }
}

extension Optic.Isomorphism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable
{
    public static func composing<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ first: Self,
        _ second: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Isomorphism {
        .init(
            forward: { second.forward(first.forward($0)) },
            backward: { first.backward(second.backward($0)) }
        )
    }

    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Isomorphism {
        Self.composing(self, next)
    }
}

extension Optic.Isomorphism
where
    Source == Target,
    Target == Focus,
    Focus == Replacement,
    Source: ~Copyable & Escapable
{
    public static var identity: Self {
        .init(forward: { $0 }, backward: { $0 })
    }
}

extension Optic.Lens
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable
{
    public static func composing<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ first: Self,
        _ second: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Lens {
        .init { source in
            let (focus, reconstruct) = first.decompose(source)
            let (nextFocus, nextReconstruct) = second.decompose(focus)
            return (
                focus: nextFocus,
                reconstruct: { replacement in
                    reconstruct(nextReconstruct(replacement))
                }
            )
        }
    }

    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Lens {
        Self.composing(self, next)
    }
}

extension Optic.Lens
where
    Source == Target,
    Target == Focus,
    Focus == Replacement
{
    public static var identity: Self {
        .init { source in
            (focus: source, reconstruct: { $0 })
        }
    }
}

extension Optic.Prism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable
{
    public static func composing<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ first: Self,
        _ second: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Prism {
        .init(
            match: { source in
                let outer = first.match(source)
                switch consume outer {
                case let .left(target):
                    return .left(target)
                case let .right(focus):
                    let inner = second.match(focus)
                    switch consume inner {
                    case let .left(replacement):
                        return .left(first.embed(replacement))
                    case let .right(nextFocus):
                        return .right(nextFocus)
                    }
                }
            },
            embed: { first.embed(second.embed($0)) }
        )
    }

    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Prism {
        Self.composing(self, next)
    }
}

extension Optic.Prism
where
    Source == Target,
    Target == Focus,
    Focus == Replacement,
    Source: ~Copyable & Escapable
{
    public static var identity: Self {
        .init(match: { .right($0) }, embed: { $0 })
    }
}

extension Optic.Affine
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & Escapable
{
    public static func composing<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ first: Self,
        _ second: Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        .init { source in
            let outer = first.decompose(source)
            switch consume outer {
            case let .left(target):
                return .left(target)
            case let .right((focus, reconstruct)):
                let inner = second.decompose(focus)
                switch consume inner {
                case let .left(replacement):
                    return .left(reconstruct(replacement))
                case let .right((nextFocus, nextReconstruct)):
                    return .right(
                        (
                            focus: nextFocus,
                            reconstruct: { replacement in
                                reconstruct(nextReconstruct(replacement))
                            }
                        )
                    )
                }
            }
        }
    }

    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        Self.composing(self, next)
    }
}

extension Optic.Affine
where
    Source == Target,
    Target == Focus,
    Focus == Replacement
{
    public static var identity: Self {
        .init { source in
            .right((focus: source, reconstruct: { $0 }))
        }
    }
}

extension Optic.Lens
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public init(_ isomorphism: Optic<Source, Target, Focus, Replacement>.Isomorphism) {
        self.init { source in
            (
                focus: isomorphism.forward(source),
                reconstruct: isomorphism.backward
            )
        }
    }
}

extension Optic.Prism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public init(_ isomorphism: Optic<Source, Target, Focus, Replacement>.Isomorphism) {
        self.init(
            match: { .right(isomorphism.forward($0)) },
            embed: isomorphism.backward
        )
    }
}

extension Optic.Affine
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public init(_ isomorphism: Optic<Source, Target, Focus, Replacement>.Isomorphism) {
        self.init { source in
            .right(
                (
                    focus: isomorphism.forward(source),
                    reconstruct: isomorphism.backward
                )
            )
        }
    }

    public init(_ lens: Optic<Source, Target, Focus, Replacement>.Lens) {
        self.init { .right(lens.decompose($0)) }
    }

    public init(_ prism: Optic<Source, Target, Focus, Replacement>.Prism) {
        self.init { source in
            let result = prism.match(source)
            switch consume result {
            case let .left(target):
                return .left(target)
            case let .right(focus):
                return .right((focus: focus, reconstruct: prism.embed))
            }
        }
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
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Lens {
        Optic<Source, Target, Focus, Replacement>.Lens(self).appending(next)
    }

    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Prism {
        Optic<Source, Target, Focus, Replacement>.Prism(self).appending(next)
    }

    public func appending<
        NextFocus: ~Copyable & Escapable,
        NextReplacement: ~Copyable & ~Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        Optic<Source, Target, Focus, Replacement>.Affine(self).appending(next)
    }
}

extension Optic.Lens
where Replacement: Escapable {
    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Lens {
        appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens(next))
    }

    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        Optic<Source, Target, Focus, Replacement>.Affine(self)
            .appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine(next))
    }
}

extension Optic.Prism
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
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Prism {
        appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism(next))
    }

    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        Optic<Source, Target, Focus, Replacement>.Affine(self)
            .appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine(next))
    }
}

extension Optic.Affine
where Replacement: Escapable {
    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Isomorphism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine(next))
    }

    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Lens
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine(next))
    }

    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Prism
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Affine {
        appending(Optic<Focus, Replacement, NextFocus, NextReplacement>.Affine(next))
    }
}
