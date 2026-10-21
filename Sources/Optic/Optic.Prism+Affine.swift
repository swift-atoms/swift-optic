extension Optic.Prism
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public func asAffine() -> Optic<Source, Target, Focus, Replacement>.Affine {
        .init { source in
            switch self.match(source) {
            case .left(let target): return .left(target)
            case .right(let focus): return .right((focus: focus, reconstruct: self.embed))
            }
        }
    }
}
