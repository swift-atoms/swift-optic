import Either

extension Optic.Traversal {
    public static func composing<
        NextFocus: Copyable & Escapable & Sendable,
        NextReplacement: Copyable & Escapable
    >(
        _ first: Self,
        _ second: Optic<Focus, Replacement, NextFocus, NextReplacement>.Traversal
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Traversal
    where Focus: Sendable {
        .init { source in
            let outer = first.decompose(source)
            let inners = outer.focuses.map(second.decompose)
            let focuses = inners.flatMap(\.focuses)

            return .init(
                focuses: focuses,
                reconstruct: { replacements in
                    var offset = 0
                    let middle = inners.map { inner in
                        let end = offset + inner.focuses.count
                        precondition(end <= replacements.endIndex)
                        let slice = Array(replacements[offset..<end])
                        offset = end
                        return inner.reconstruct(slice)
                    }
                    precondition(offset == replacements.endIndex)
                    return outer.reconstruct(middle)
                }
            )
        }
    }

    public func appending<
        NextFocus: Copyable & Escapable & Sendable,
        NextReplacement: Copyable & Escapable
    >(
        _ next: Optic<Focus, Replacement, NextFocus, NextReplacement>.Traversal
    ) -> Optic<Source, Target, NextFocus, NextReplacement>.Traversal
    where Focus: Sendable {
        Self.composing(self, next)
    }

    public func get(_ source: consuming Source) -> [Focus] {
        decompose(source).focuses
    }

    public func count(_ source: consuming Source) -> Int {
        get(source).count
    }

    public func isEmpty(_ source: consuming Source) -> Bool {
        get(source).isEmpty
    }

    public func set(
        _ source: consuming Source,
        _ replacement: Replacement
    ) -> Target {
        map(source) { _ in replacement }
    }
}

extension Optic.Traversal
where
    Source == [Focus],
    Target == [Replacement]
{
    public static var each: Self {
        .init { source in
            .init(focuses: source, reconstruct: { $0 })
        }
    }
}

extension Optic.Traversal
where
    Source == Target,
    Target == Focus,
    Focus == Replacement
{
    public static var identity: Self {
        .init { source in
            .init(
                focuses: [source],
                reconstruct: { replacements in
                    precondition(replacements.count == 1)
                    return replacements[0]
                }
            )
        }
    }
}

extension Optic.Traversal {
    public init(_ isomorphism: Optic<Source, Target, Focus, Replacement>.Isomorphism) {
        self.init { source in
            .init(
                focuses: [isomorphism.forward(source)],
                reconstruct: { replacements in
                    precondition(replacements.count == 1)
                    return isomorphism.backward(replacements[0])
                }
            )
        }
    }

    public init(_ lens: Optic<Source, Target, Focus, Replacement>.Lens) {
        self.init { source in
            let (focus, reconstruct) = lens.decompose(source)
            return .init(
                focuses: [focus],
                reconstruct: { replacements in
                    precondition(replacements.count == 1)
                    return reconstruct(replacements[0])
                }
            )
        }
    }
}

extension Optic.Traversal
where Target: Copyable & Sendable {
    public init(_ prism: Optic<Source, Target, Focus, Replacement>.Prism) {
        self.init { source in
            let result = prism.match(source)
            switch result {
            case let .left(target):
                return .init(focuses: [], reconstruct: { _ in target })
            case let .right(focus):
                return .init(
                    focuses: [focus],
                    reconstruct: { replacements in
                        precondition(replacements.count == 1)
                        return prism.embed(replacements[0])
                    }
                )
            }
        }
    }

    public init(_ affine: Optic<Source, Target, Focus, Replacement>.Affine) {
        self.init { source in
            let decomposition = affine.decompose(source)
            switch decomposition {
            case let .left(target):
                return .init(focuses: [], reconstruct: { _ in target })
            case let .right((focus, reconstruct)):
                return .init(
                    focuses: [focus],
                    reconstruct: { replacements in
                        precondition(replacements.count == 1)
                        return reconstruct(replacements[0])
                    }
                )
            }
        }
    }
}

extension Optic.Traversal
where
    Source == Target,
    Source: Copyable & Sendable,
    Focus == Replacement
{
    public init(
        get: @escaping @Sendable (Source) -> [Focus],
        modify: @escaping @Sendable (Source, (Focus) -> Focus) -> Source
    ) {
        self.init { source in
            let focuses = get(source)
            return .init(
                focuses: focuses,
                reconstruct: { replacements in
                    var index = 0
                    let target = modify(source) { _ in
                        defer { index += 1 }
                        precondition(index < replacements.count)
                        return replacements[index]
                    }
                    precondition(index == replacements.count)
                    return target
                }
            )
        }
    }
}

extension Optic.Traversal
where
    Source == Target,
    Source: Copyable,
    Focus == Replacement
{
    public func modify(
        _ source: consuming Source,
        _ transform: (Focus) -> Focus
    ) -> Target {
        map(source, transform)
    }
}
