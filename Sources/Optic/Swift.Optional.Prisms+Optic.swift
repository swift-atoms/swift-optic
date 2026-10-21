import Either

extension Swift::Optional.Prisms {
    public var none: Optic<Optional, Optional, Void, Void>.Prism {
        .init(
            match: { source in
                switch source {
                case .none: return .right(())
                case .some(let wrapped): return .left(.some(wrapped))
                }
            },
            embed: { _ in .none }
        )
    }

    public var some: Optic<Optional, Optional, Wrapped, Wrapped>.Prism {
        .init(
            match: { source in
                switch source {
                case .none: return .left(.none)
                case .some(let wrapped): return .right(wrapped)
                }
            },
            embed: Optional.some
        )
    }

    @_disfavoredOverload
    public subscript<Member: Copyable & Escapable>(
        dynamicMember keyPath: KeyPath<
            Wrapped.Prisms,
            Optic<Wrapped, Wrapped, Member, Member>.Prism
        >
    ) -> Optic<Optional, Optional, Member?, Member?>.Prism
    where Wrapped: Optic<Wrapped, Wrapped, Wrapped, Wrapped>.Prism.Accessible {
        let prism = Wrapped.prisms[keyPath: keyPath]
        return .init(
            match: { source in
                switch source {
                case .none:
                    return .left(.none)
                case .some(let wrapped):
                    let result = prism.match(wrapped)
                    switch result {
                    case .left(let unmatched): return .left(.some(unmatched))
                    case .right(let member): return .right(.some(member))
                    }
                }
            },
            embed: { member in
                switch member {
                case .none: return .none
                case .some(let member): return .some(prism.embed(member))
                }
            }
        )
    }
}
