import Either

extension Optic.Isomorphism
where Replacement: Escapable {
    public func map(
        _ source: consuming Source,
        _ transform: (consuming Focus) -> Replacement
    ) -> Target {
        backward(transform(forward(source)))
    }
}

extension Optic.Lens
where Replacement: Escapable {
    public func map(
        _ source: consuming Source,
        _ transform: (consuming Focus) -> Replacement
    ) -> Target {
        let decomposition = decompose(source)
        return decomposition.reconstruct(transform(decomposition.focus))
    }
}

extension Optic.Prism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable,
    Focus: ~Copyable,
    Replacement: ~Copyable & ~Escapable
{
    public func matches(_ source: consuming Source) -> Bool {
        let result = match(source)
        switch consume result {
        case .left: return false
        case .right: return true
        }
    }

    public func extract(_ source: consuming Source) -> Focus? {
        let result = match(source)
        switch consume result {
        case .left: return nil
        case let .right(focus): return focus
        }
    }
}

extension Optic.Prism
where Replacement: Escapable {
    public func map(
        _ source: consuming Source,
        _ transform: (consuming Focus) -> Replacement
    ) -> Target {
        let result = match(source)
        switch consume result {
        case let .left(target): return target
        case let .right(focus): return embed(transform(focus))
        }
    }
}

extension Optic.Affine {
    public func isPresent(_ source: consuming Source) -> Bool {
        let decomposition = decompose(source)
        switch consume decomposition {
        case .left: return false
        case .right: return true
        }
    }

    public func extract(_ source: consuming Source) -> Focus? {
        let decomposition = decompose(source)
        switch consume decomposition {
        case .left: return nil
        case let .right((focus, _)): return focus
        }
    }
}

extension Optic.Isomorphism
where
    Source == Target,
    Target: Copyable,
    Focus == Replacement,
    Focus: Copyable
{
    public func modify(_ source: consuming Source, _ transform: (Focus) -> Focus) -> Target {
        map(source, transform)
    }

    public func modify(_ source: inout Source, _ transform: (Focus) -> Focus) {
        source = map(source, transform)
    }
}

extension Optic.Lens
where
    Source == Target,
    Target: Copyable,
    Focus == Replacement,
    Focus: Copyable
{
    public func modify(_ source: consuming Source, _ transform: (Focus) -> Focus) -> Target {
        map(source, transform)
    }

    public func modify(_ source: inout Source, _ transform: (Focus) -> Focus) {
        source = map(source, transform)
    }
}

extension Optic.Prism
where
    Source == Target,
    Target: Copyable,
    Focus == Replacement,
    Focus: Copyable
{
    public func modify(_ source: consuming Source, _ transform: (Focus) -> Focus) -> Target {
        map(source, transform)
    }

    public func modify(_ source: inout Source, _ transform: (inout Focus) -> Void) {
        source = map(source) { focus in
            var focus = focus
            transform(&focus)
            return focus
        }
    }
}

extension Optic.Affine
where
    Source == Target,
    Target: Copyable,
    Focus == Replacement,
    Focus: Copyable
{
    public func modify(_ source: consuming Source, _ transform: (Focus) -> Focus) -> Target {
        map(source, transform)
    }

    public func modify(_ source: inout Source, _ transform: (inout Focus) -> Void) {
        source = map(source) { focus in
            var focus = focus
            transform(&focus)
            return focus
        }
    }
}
