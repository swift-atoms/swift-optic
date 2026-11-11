/// A type whose stored parts are available as fields, by name, from `Self.fields`.
///
/// The `@Fields` macro makes a struct conform. Generic code takes a part of any such type as a
/// function of its namespace, `(Whole.Fields) -> Optic<Whole, Whole, Part, Part>.Field`, which a
/// caller writes as `{ $0.name }`.
public protocol __OpticFieldAccessible {
    associatedtype Fields
    static var fields: Fields { get }
}

extension Optic.Field {
    public typealias Accessible = __OpticFieldAccessible
}
