import Either
import Optic
import Testing

private struct ScopedValue: ~Copyable, ~Escapable {
    let value: Int
}

private enum ScopedChoice: ~Copyable, ~Escapable {
    case value(Int)
    case empty
}

private struct LinearResult: ~Copyable {
    let value: Int
}

private struct ScopedReplacement: ~Copyable, ~Escapable {
    let value: Int
}

@Suite
private struct `Capability Tests` {
    @Test
    func `adapter consumes noncopyable nonescapable input sorts`() {
        let adapter = Optic<
            ScopedValue,
            LinearResult,
            LinearResult,
            ScopedValue
        >.Adapter(
            forward: { .init(value: $0.value) },
            backward: { .init(value: $0.value) }
        )

        #expect(adapter.forward(ScopedValue(value: 1)).value == 1)
        #expect(adapter.backward(ScopedValue(value: 2)).value == 2)
    }

    @Test
    func `isomorphism consumes noncopyable nonescapable input sorts`() {
        let isomorphism = Optic<
            ScopedValue,
            LinearResult,
            LinearResult,
            ScopedValue
        >.Isomorphism(
            forward: { .init(value: $0.value) },
            backward: { .init(value: $0.value) }
        )

        #expect(isomorphism.forward(ScopedValue(value: 3)).value == 3)
        #expect(isomorphism.backward(ScopedValue(value: 4)).value == 4)
    }

    @Test
    func `lens consumes noncopyable nonescapable input sorts`() {
        let lens = Optic<
            ScopedValue,
            LinearResult,
            LinearResult,
            ScopedValue
        >.Lens(
            decompose: { source in
                (
                    focus: LinearResult(value: source.value),
                    reconstruct: { replacement in
                        LinearResult(value: replacement.value)
                    }
                )
            }
        )

        #expect(lens.get(ScopedValue(value: 5)).value == 5)
        #expect(
            lens.set(ScopedValue(value: 6), ScopedValue(value: 7)).value == 7
        )
    }

    @Test
    func `traversal consumes a noncopyable nonescapable source`() {
        let traversal = Optic<ScopedValue, LinearResult, Int, String>.Traversal(
            decompose: { source in
                .init(
                    focuses: [source.value, source.value + 1],
                    reconstruct: { .init(value: $0.count) }
                )
            }
        )

        #expect(
            traversal.map(ScopedValue(value: 8)) { "value=\($0)" }
                .value == 2
        )
    }

    @Test
    func `affine traversal preserves noncopyable result sorts`() {
        let traversal = Optic<
            ScopedChoice,
            LinearResult,
            LinearResult,
            LinearResult
        >.Affine(
            decompose: { source in
                switch consume source {
                case let .value(value):
                    .right(
                        (
                            focus: LinearResult(value: value),
                            reconstruct: {
                                LinearResult(value: $0.value)
                            }
                        )
                    )
                case .empty:
                    .left(LinearResult(value: -1))
                }
            }
        )

        let result = traversal.map(.value(10)) { _ in
            LinearResult(value: 11)
        }

        #expect(result.value == 11)
    }

    @Test
    func `affine representation admits a nonescapable replacement`() {
        let traversal = Optic<
            ScopedChoice,
            LinearResult,
            LinearResult,
            ScopedReplacement
        >.Affine(
            decompose: { source in
                switch consume source {
                case let .value(value):
                    .right(
                        (
                            focus: LinearResult(value: value),
                            reconstruct: { .init(value: $0.value) }
                        )
                    )
                case .empty:
                    .left(LinearResult(value: -1))
                }
            }
        )

        _ = traversal
    }
}
