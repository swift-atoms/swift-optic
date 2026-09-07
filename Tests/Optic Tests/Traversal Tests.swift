import Optic
import Testing

private struct Inventory<Value>: Equatable, Sendable where Value: Equatable & Sendable {
    var values: [Value]
    var label: String
}

@Suite
private struct `Traversal families preserve focus order and outer structure` {
    let traversal = Optic<
        Inventory<Int>,
        Inventory<String>,
        Int,
        String
    >.Traversal(
        decompose: { source in
            .init(
                focuses: source.values,
                reconstruct: { Inventory<String>(values: $0, label: source.label) }
            )
        }
    )

    @Test
    func `bazaar preserves focus order`() {
        let source = Inventory(values: [1, 2, 3], label: "numbers")
        #expect(traversal.decompose(source).focuses == [1, 2, 3])
    }

    @Test
    func `mapping changes focus and structure types`() {
        let source = Inventory(values: [1, 2, 3], label: "numbers")
        let target = traversal.map(source) { "value=\($0)" }
        #expect(
            target == Inventory(
                values: ["value=1", "value=2", "value=3"],
                label: "numbers"
            )
        )
    }

    @Test
    func `empty focus collection reconstructs the same outer shape`() {
        let source = Inventory<Int>(values: [], label: "empty")
        #expect(traversal.map(source) { "\($0)" } == Inventory(values: [], label: "empty"))
    }
}
