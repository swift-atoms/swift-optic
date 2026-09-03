extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: Copyable & Escapable,
    Replacement: Copyable & Escapable
{
    public struct Setter {
        public var modify: (
            consuming Source,
            (consuming Focus) -> Replacement
        ) -> Target

        public init(
            modify: @escaping (
                consuming Source,
                (consuming Focus) -> Replacement
            ) -> Target
        ) {
            self.modify = modify
        }
    }
}

extension Optic.Setter
where Replacement: Escapable {
    public static func composing<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ first: Self,
        _ second: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
        .init { source, transform in
            first.modify(source) { focus in
                second.modify(focus, transform)
            }
        }
    }

    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
        Self.composing(self, next)
    }

    public func over(
        _ source: consuming Source,
        _ transform: @escaping (consuming Focus) -> Replacement
    ) -> Target {
        modify(source, transform)
    }

    public func set(
        _ source: consuming Source,
        to replacement: Replacement
    ) -> Target
    {
        modify(source) { _ in replacement }
    }
}

extension Optic.Setter
where
    Source == Target,
    Target == Focus,
    Focus == Replacement
{
    public static var identity: Self {
        .init { source, transform in transform(source) }
    }
}

extension Optic.Setter
where
    Source == Target,
    Focus == Replacement
{
    public func over(
        _ source: inout Source,
        _ transform: @escaping (consuming Focus) -> Replacement
    ) {
        source = modify(source, transform)
    }

    public func set(_ source: inout Source, to replacement: Replacement) {
        source = modify(source) { _ in replacement }
    }
}

extension Optic.Setter {
    public init(_ isomorphism: Optic<Source, Target, Focus, Replacement>.Isomorphism) {
        self.init { source, transform in
            isomorphism.backward(transform(isomorphism.forward(source)))
        }
    }

    public init(_ lens: Optic<Source, Target, Focus, Replacement>.Lens) {
        self.init { source, transform in lens.map(source, transform) }
    }

    public init(_ prism: Optic<Source, Target, Focus, Replacement>.Prism) {
        self.init { source, transform in prism.map(source, transform) }
    }

    public init(_ affine: Optic<Source, Target, Focus, Replacement>.Affine) {
        self.init { source, transform in affine.map(source, transform) }
    }

    public init(_ traversal: Optic<Source, Target, Focus, Replacement>.Traversal) {
        self.init { source, transform in traversal.map(source, transform) }
    }
}

extension Optic.Isomorphism
where
    Focus: Copyable,
    Replacement: Copyable & Escapable
{
    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
        Optic<Source, Target, Focus, Replacement>.Setter(self).appending(next)
    }
}

extension Optic.Lens
where
    Focus: Copyable,
    Replacement: Copyable & Escapable
{
    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
        Optic<Source, Target, Focus, Replacement>.Setter(self).appending(next)
    }
}

extension Optic.Prism
where
    Focus: Copyable,
    Replacement: Copyable & Escapable
{
    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
        Optic<Source, Target, Focus, Replacement>.Setter(self).appending(next)
    }
}

extension Optic.Affine
where
    Focus: Copyable,
    Replacement: Copyable & Escapable
{
    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
        Optic<Source, Target, Focus, Replacement>.Setter(self).appending(next)
    }
}

extension Optic.Traversal {
    public func appending<
        NextFocus: Copyable & Escapable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Setter
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Setter {
        Optic<Source, Target, Focus, Replacement>.Setter(self).appending(next)
    }
}
