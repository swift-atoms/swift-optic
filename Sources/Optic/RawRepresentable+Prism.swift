import Either

public struct Prisms<Represented: RawRepresentable>: Sendable {
    public init() {}
}

extension RawRepresentable
where
    Self: Copyable & Escapable & SendableMetatype,
    RawValue: Copyable & Escapable
{
    public static var prisms: Prisms<Self> { .init() }
}

extension Prisms
where
    Represented: Copyable & Escapable & SendableMetatype,
    Represented.RawValue: Copyable & Escapable
{
    /// Matches a raw value without discarding an unrepresentable value.
    ///
    /// - Law: Lawfulness relies on the semantic `RawRepresentable` round-trip
    ///   contract; Swift does not mechanically enforce that contract.
    public var rawValue: Optic<
        Represented.RawValue,
        Represented.RawValue,
        Represented,
        Represented
    >.Prism {
        .init(
            match: { rawValue in
                guard let represented = Represented(rawValue: rawValue) else {
                    return .left(rawValue)
                }
                return .right(represented)
            },
            embed: { $0.rawValue }
        )
    }
}
