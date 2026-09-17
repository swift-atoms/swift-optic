import Traversal_Macro
import Optic
import Testing

@Traversals
private struct Inventory: Sendable {
    var values: [Int]
}

@Traversals
private struct GenericInventory<Value: Sendable>: Sendable {
    var values: [Value]
    var label: String
}

@Test
func `derived traversal extracts and transforms every element`() {
    let traversal = Inventory.traversals.values
    let inventory = Inventory(values: [1, 2, 3])

    #expect(traversal.decompose(inventory).focuses == [1, 2, 3])
    #expect(traversal.map(inventory) { $0 * 2 }.values == [2, 4, 6])
}

@Test
func `derived traversal transforms a generic family`() {
    let traversal = GenericInventory<Int>.traversals.values(to: String.self)
    let source = GenericInventory(values: [1, 2, 3], label: "numbers")

    let target = traversal.map(source) { "value=\($0)" }
    #expect(target.values == ["value=1", "value=2", "value=3"])
    #expect(target.label == "numbers")
}
