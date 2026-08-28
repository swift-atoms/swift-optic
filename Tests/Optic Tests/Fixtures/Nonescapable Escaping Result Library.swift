import Either

public enum Family<
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & ~Escapable,
    Focus: ~Copyable & ~Escapable,
    Replacement: ~Copyable & ~Escapable
> {}

extension Family where Focus: Escapable {
    public struct TargetRelaxedPrism {
        public let match: (consuming Source) -> Either<Target, Focus>
        public let embed: (consuming Replacement) -> Target

        public init(
            match: @escaping (consuming Source) -> Either<Target, Focus>,
            embed: @escaping (consuming Replacement) -> Target
        ) {
            self.match = match
            self.embed = embed
        }
    }
}

extension Family where Target: Escapable {
    public struct FocusRelaxedPrism {
        public let match: (consuming Source) -> Either<Target, Focus>
        public let embed: (consuming Replacement) -> Target

        public init(
            match: @escaping (consuming Source) -> Either<Target, Focus>,
            embed: @escaping (consuming Replacement) -> Target
        ) {
            self.match = match
            self.embed = embed
        }
    }
}
