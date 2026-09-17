public import Isomorphism_Macro
import Testing

@Isomorphism
private struct Coordinate: Equatable {
    var x: Int
    var y: Int
}

@Isomorphism
private struct Box<Value> {
    var value: Value
}

@Isomorphism
private struct ProjectedRecord: Equatable {
    static let format = "v1"
    var value: Int
    var doubled: Int { value * 2 }
}

@Isomorphism
public struct PublicBox<Value> {
    public var value: Value
}

@Test
func `derived isomorphism round trips both representations`() {
    let coordinate = Coordinate(x: 2, y: 3)
    let parts = Coordinate.isomorphisms.memberwise.forward(coordinate)

    #expect(parts.0 == 2)
    #expect(parts.1 == 3)
    #expect(Coordinate.isomorphisms.memberwise.backward(parts) == coordinate)
}

@Test
func `derived isomorphism transforms a generic family`() {
    let isomorphism = Box<Int>.isomorphisms.memberwise(to: String.self)

    #expect(isomorphism.forward(Box(value: 42)) == 42)
    #expect(isomorphism.backward("forty-two").value == "forty-two")
}

@Test
func `derived isomorphism projects stored instance properties only`() {
    let record = ProjectedRecord(value: 21)

    #expect(ProjectedRecord.isomorphisms.memberwise.forward(record) == 21)
    #expect(ProjectedRecord.isomorphisms.memberwise.backward(42) == ProjectedRecord(value: 42))
}

@Test
func `public generic derivation exposes its type changing projection`() {
    let isomorphism = PublicBox<Int>.isomorphisms.memberwise(to: String.self)

    #expect(isomorphism.forward(PublicBox(value: 42)) == 42)
    #expect(isomorphism.backward("forty-two").value == "forty-two")
}
