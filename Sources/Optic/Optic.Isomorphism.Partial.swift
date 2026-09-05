extension Optic.Isomorphism
where
    Source: ~Copyable & Escapable,
    Focus: ~Copyable & Escapable,
    Source == Target,
    Focus == Replacement
{
    /// A correspondence between supported subsets of Source and Focus.
    ///
    /// Unlike an Adapter, this value claims inverse laws. Whenever `forward`
    /// succeeds, `backward` must succeed on its result and recover the original
    /// source. Whenever `backward` succeeds, `forward` must succeed on its result
    /// and recover the original focus. Equality is semantic and does not require
    /// either representation to conform to Equatable.
    ///
    /// The two directions may have different failures. Captured context must
    /// retain a stable interpretation throughout the correspondence's use.
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
    /// A total isomorphism also satisfies the partial correspondence laws.
    public var partial: Partial<Never, Never> {
        .init(forward: forward, backward: backward)
    }
}
