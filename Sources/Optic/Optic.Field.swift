extension Optic
where
    Source == Target,
    Source: Copyable & Escapable,
    Focus == Replacement,
    Focus: Copyable & Escapable
{
    /// A stored part of a value: it is read, changed in place, and told apart from another.
    ///
    /// An `Optic.Lens` replaces a part by rebuilding the whole from a copy. A field changes the
    /// part where it is stored, so nothing else in the whole is copied, and it carries an
    /// ``Identity`` so that two fields can be compared without comparing closures. Its
    /// ``lens`` is the same part as an `Optic.Lens`.
    ///
    /// The laws are the lens laws, stated for `modify`: reading after a change gives the changed
    /// part, a change that does nothing leaves the whole as it was, and of two changes the last
    /// one wins.
    public struct Field {
        public let identity: __OpticFieldIdentity
        public let get: (Source) -> Focus
        public let modify: (inout Source, (inout Focus) -> Swift::Void) -> Swift::Void

        public init(
            identity: __OpticFieldIdentity,
            get: @escaping (Source) -> Focus,
            modify: @escaping (inout Source, (inout Focus) -> Swift::Void) -> Swift::Void
        ) {
            self.identity = identity
            self.get = get
            self.modify = modify
        }
    }
}

extension Optic.Field {
    public typealias Identity = __OpticFieldIdentity

    public func set(_ source: inout Source, to replacement: Focus) {
        modify(&source) { $0 = replacement }
    }

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
