extension Optic.Field {
    /// The same part as a lens: `set` copies the whole, changes the part in the copy and returns it.
    public var lens: Optic<Source, Source, Focus, Focus>.Lens {
        .init(
            get: get,
            set: { [modify] source, replacement in
                var whole = source
                modify(&whole) { $0 = replacement }
                return whole
            }
        )
    }
}
