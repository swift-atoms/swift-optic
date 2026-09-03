import Either

extension Optional: __OpticPrismAccessible where Wrapped: Copyable & Escapable {
    @dynamicMemberLookup
    public struct Prisms {
        public init() {}
    }

    public static var prisms: Prisms { .init() }
}

extension Optional.Prisms {
    public var none: Optic<Optional, Optional, Void, Void>.Prism {
        .init(
            match: { source in
                switch source {
                case .none: return .right(())
                case let .some(wrapped): return .left(.some(wrapped))
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
                case let .some(wrapped): return .right(wrapped)
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
                case let .some(wrapped):
                    let result = prism.match(wrapped)
                    switch result {
                    case let .left(unmatched): return .left(.some(unmatched))
                    case let .right(member): return .right(.some(member))
                    }
                }
            },
            embed: { member in
                switch member {
                case .none: return .none
                case let .some(member): return .some(prism.embed(member))
                }
            }
        )
    }
}
