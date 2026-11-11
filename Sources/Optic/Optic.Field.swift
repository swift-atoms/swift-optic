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
        public typealias Identity = __OpticFieldIdentity

        public let identity: Identity
        public let get: (Source) -> Focus
        public let modify: (inout Source, (inout Focus) -> Swift::Void) -> Swift::Void

        public init(
            identity: Identity,
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
    /// A field for the stored property at `position` in its type's declaration order.
    public init(
        _ position: Swift::Int,
        get: @escaping (Source) -> Focus,
        modify: @escaping (inout Source, (inout Focus) -> Swift::Void) -> Swift::Void
    ) {
        self.init(identity: .init(position), get: get, modify: modify)
    }

    public func set(_ source: inout Source, to replacement: Focus) {
        modify(&source) { $0 = replacement }
    }
}
