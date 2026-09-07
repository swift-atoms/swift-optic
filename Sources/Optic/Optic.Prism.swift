public import Either

extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    @dynamicMemberLookup
    public struct Prism {
        public var match: (consuming Source) -> Either<Target, Focus>
        public var embed: (consuming Replacement) -> Target










        public init(
            match: @escaping (consuming Source) -> Either<Target, Focus>,
            embed: @escaping (consuming Replacement) -> Target
        ) {
            self.match = match
            self.embed = embed
        }
    }
}

extension Optic.Prism
where
    Source == Target,
    Source: Copyable & Escapable,
    Focus == Replacement
{
    public init(
        embed: @escaping (Replacement) -> Target,
        extract: @escaping (Source) -> Focus?
    ) {
        self.init(
            match: { source in
                if let focus = extract(source) {
                    return .right(focus)
                }
                return .left(source)
            },
            embed: embed
        )
    }
}
