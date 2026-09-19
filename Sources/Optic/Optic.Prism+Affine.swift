extension Optic.Prism
where Source: ~Copyable & ~Escapable, Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable, Replacement: ~Copyable & ~Escapable
{
    public func asAffine() -> Optic<Source, Target, Focus, Replacement>.Affine {
        .init { source in
            switch self.match(source) {
            case let .left(target): return .left(target)
            case let .right(focus): return .right((focus: focus, reconstruct: self.embed))
            }
        }
    }
}
