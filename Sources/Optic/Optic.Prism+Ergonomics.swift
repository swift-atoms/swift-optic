public protocol __OpticPrismAccessible {
    associatedtype Prisms
    static var prisms: Prisms { get }
}

extension Optic.Prism {
    public typealias Accessible = __OpticPrismAccessible
}

extension Optic.Prism
where
    Focus == Replacement,
    Focus: Copyable & Escapable & Accessible
{
    public subscript<NextFocus: Copyable & Escapable>(
        dynamicMember keyPath: KeyPath<
            Focus.Prisms,
            Optic<Focus, Focus, NextFocus, NextFocus>.Prism
        >
    ) -> Optic<Source, Target, NextFocus, NextFocus>.Prism {
        appending(Focus.prisms[keyPath: keyPath])
    }
}

extension Optic.Prism
where Source: Copyable {
    public static func ~= (pattern: Self, value: Source) -> Bool {
        pattern.matches(value)
    }
}
