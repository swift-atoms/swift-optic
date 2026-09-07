extension Optic.Isomorphism
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{










    public struct Partial<ForwardFailure: Swift.Error, BackwardFailure: Swift.Error> {
        public let adapter: Optic<Source, Source, Focus, Focus>
            .Adapter<ForwardFailure, BackwardFailure>

        public init(
            forward: @escaping (consuming Source) throws(ForwardFailure) -> Focus,
            backward: @escaping (consuming Focus) throws(BackwardFailure) -> Source
        ) {
            self.adapter = .init(forward: forward, backward: backward)
        }
    }
}

extension Optic.Isomorphism.Partial
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{
    internal init(adapter: Optic<Source, Source, Focus, Focus>.Adapter<ForwardFailure, BackwardFailure>) {
        self.adapter = adapter
    }

    public var forward: (consuming Source) throws(ForwardFailure) -> Focus {
        adapter.forward
    }

    public var backward: (consuming Focus) throws(BackwardFailure) -> Source {
        adapter.backward
    }

    public var reversed: Optic<Focus, Focus, Source, Source>
        .Isomorphism.Partial<BackwardFailure, ForwardFailure>
    {
        .init(forward: backward, backward: forward)
    }
}

extension Optic.Isomorphism
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{

    public var partial: Partial<Never, Never> {
        .init(forward: forward, backward: backward)
    }
}
