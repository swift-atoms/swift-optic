public import Lens_Macro
import Testing

@Lenses
private struct Person: Equatable {
    var name: String
    var age: Int
}

@Lenses
private struct Box<Value> {
    var value: Value
}

@Lenses
private struct ProjectedRecord: Equatable {
    static let format = "v1"
    var value: Int
    var doubled: Int { value * 2 }
}

@Lenses
public struct PublicBox<Value> {
    public var value: Value
}

@Test
func `derived lens obeys get set and set set`() {
    let person = Person(name: "Blob", age: 42)
    let lens = Person.lenses.name

    #expect(lens.set(person, lens.get(person)) == person)
    #expect(lens.get(lens.set(person, "Blob Jr.")) == "Blob Jr.")
    #expect(lens.set(lens.set(person, "First"), "Last") == lens.set(person, "Last"))
}

@Test
func `derived lens transforms a generic family`() {
    let lens = Box<Int>.lenses.value(to: String.self)

    #expect(lens.get(Box(value: 42)) == 42)
    #expect(lens.set(Box(value: 42), "forty-two").value == "forty-two")
}

@Test
func `derived lenses include stored instance properties only`() {
    let record = ProjectedRecord(value: 21)

    #expect(ProjectedRecord.lenses.value.get(record) == 21)
    #expect(ProjectedRecord.lenses.value.set(record, 42) == ProjectedRecord(value: 42))
}

@Test
func `public generic derivation exposes its type changing lens`() {
    let lens = PublicBox<Int>.lenses.value(to: String.self)

    #expect(lens.get(PublicBox(value: 42)) == 42)
    #expect(lens.set(PublicBox(value: 42), "forty-two").value == "forty-two")
}
