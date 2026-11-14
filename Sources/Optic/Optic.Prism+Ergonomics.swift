public protocol __OpticPrismAccessible: ~Copyable {
    associatedtype Prisms
    static var prisms: Prisms { get }
}

extension Optic.Prism {
    public typealias Accessible = __OpticPrismAccessible
}

extension __OpticPrismAccessible where Self: Copyable {

    public subscript<Focus: Copyable & Escapable>(
        dynamicMember keyPath: KeyPath<Prisms, Optic<Self, Self, Focus, Focus>.Prism>
    ) -> Focus? {
        Self.prisms[keyPath: keyPath].extract(self)
    }

    public func `is`<Focus: Copyable & Escapable>(
        _ keyPath: KeyPath<Prisms, Optic<Self, Self, Focus, Focus>.Prism>
    ) -> Bool {
        Self.prisms[keyPath: keyPath].matches(self)
    }

    public mutating func modify<Focus: Copyable & Escapable, Failure: Error>(
        _ keyPath: KeyPath<Prisms, Optic<Self, Self, Focus, Focus>.Prism>,
        _ transform: (inout Focus) throws(Failure) -> Void
    ) throws(Failure) {
        let prism = Self.prisms[keyPath: keyPath]
        guard var focus = prism.extract(self) else { return }
        try transform(&focus)
        self = prism.embed(focus)
    }
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
