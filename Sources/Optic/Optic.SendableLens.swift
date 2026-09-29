extension Optic
where Source: Copyable & Escapable, Target: Copyable & Escapable,
    Focus: Copyable & Escapable, Replacement: Copyable & Escapable
{
    public struct SendableLens: Swift.Sendable {
        public let get: @Sendable (Source) -> Focus
        public let set: @Sendable (Source, Replacement) -> Target

        public init(
            get: @escaping @Sendable (Source) -> Focus,
            set: @escaping @Sendable (Source, Replacement) -> Target
        ) {
            self.get = get
            self.set = set
        }
    }
}
