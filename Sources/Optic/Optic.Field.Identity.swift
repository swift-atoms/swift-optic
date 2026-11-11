/// Which stored part an `Optic.Field` focuses, as positions known when the program is compiled.
///
/// A field made for one stored property has one position: that property's place in its type, in
/// declaration order. Composing two fields appends the second field's positions to the first's.
/// Two fields of the same source and focus types with equal identities focus the same part.
public struct __OpticFieldIdentity: Swift::Hashable, Swift::Sendable {
    public let positions: [Swift::Int]

    public init(_ position: Swift::Int) {
        self.positions = [position]
    }

    public init(positions: [Swift::Int]) {
        self.positions = positions
    }
}

extension __OpticFieldIdentity {
    public func appending(_ other: Self) -> Self {
        .init(positions: positions + other.positions)
    }
}
