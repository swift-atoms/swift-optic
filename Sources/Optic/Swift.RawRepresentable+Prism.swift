import Either

public struct Prisms<Represented: Swift.RawRepresentable>: Sendable {
    public init() {}
}

extension Swift.RawRepresentable
where
    Self: Copyable & Escapable,
    RawValue: Copyable & Escapable
{
    public static var prisms: Prisms<Self> { .init() }
}

extension Prisms
where
    Represented: Copyable & Escapable,
    Represented.RawValue: Copyable & Escapable
{
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
