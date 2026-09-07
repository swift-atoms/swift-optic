extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{
    public struct Isomorphism {
        public var forward: (consuming Source) -> Focus
        public var backward: (consuming Replacement) -> Target








        public init(
            forward: @escaping (consuming Source) -> Focus,
            backward: @escaping (consuming Replacement) -> Target
        ) {
            self.forward = forward
            self.backward = backward
        }
    }
}
