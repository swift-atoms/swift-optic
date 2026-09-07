extension Optic
where
    Source: ~Copyable & ~Escapable,
    Target: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Replacement: ~Copyable & ~Escapable
{




    public struct Adapter<
        ForwardFailure: Swift.Error,
        BackwardFailure: Swift.Error
    > {
        public var forward:
            (consuming Source) throws(ForwardFailure) -> Focus
        public var backward:
            (consuming Replacement) throws(BackwardFailure) -> Target

        public init(
            forward: @escaping
                (consuming Source) throws(ForwardFailure) -> Focus,
            backward: @escaping
                (consuming Replacement) throws(BackwardFailure) -> Target
        ) {
            self.forward = forward
            self.backward = backward
        }
    }
}
