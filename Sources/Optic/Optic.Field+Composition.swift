extension Optic.Field {
    /// The part of this field's part that `next` focuses. Its identity is this field's positions
    /// followed by `next`'s.
    public func appending<Part: Copyable & Escapable>(
        _ next: Optic<Focus, Focus, Part, Part>.Field
    ) -> Optic<Source, Source, Part, Part>.Field {
        .init(
            identity: identity.appending(next.identity),
            get: { [get] source in next.get(get(source)) },
            modify: { [modify] source, transform in
                modify(&source) { focus in next.modify(&focus, transform) }
            }
        )
    }
}
