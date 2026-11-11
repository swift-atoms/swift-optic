public import Field_Macro
import Testing

@Fields
private struct Counter: Equatable {
    var count = 0
    var name = ""
    var tags: [String] = []
}

@Fields
private struct Mixed: Equatable {
    static let format = "v1"
    let id: Int
    var value = 21
    var doubled: Int { value * 2 }
    var observed = 0 {
        didSet { changes += 1 }
    }
    var changes = 0
}

@propertyWrapper
private struct ReadOnly {
    var wrappedValue: Int { 1 }
}

@Fields
private struct Wrapped {
    var before = 0
    @ReadOnly var constant
    var after = 0
}

@Fields
private struct Inner: Equatable {
    var isOn = false
}

@Fields
private struct Outer: Equatable {
    var label = ""
    var inner = Inner()
}

@Fields
private struct Box<Value> {
    var value: Value
}

@Fields
public struct Tally {
    public var count = 0

    public init() {}
}

private func read<Whole: __OpticFieldAccessible, Part>(
    _ whole: Whole,
    _ select: (Whole.Fields) -> Optic<Whole, Whole, Part, Part>.Field
) -> Part {
    select(Whole.fields).get(whole)
}

private func write<Whole: __OpticFieldAccessible, Part>(
    _ whole: inout Whole,
    _ select: (Whole.Fields) -> Optic<Whole, Whole, Part, Part>.Field,
    to part: Part
) {
    select(Whole.fields).set(&whole, to: part)
}

@Test
func `a derived field needs no written type and changes its property in place`() {
    var counter = Counter()
    Counter.fields.count.modify(&counter) { $0 += 2 }
    Counter.fields.name.set(&counter, to: "Blob")
    Counter.fields.tags.modify(&counter) { $0.append("a") }
    #expect(counter == Counter(count: 2, name: "Blob", tags: ["a"]))
    #expect(Counter.fields.count.get(counter) == 2)
}

@Test
func `derived fields are numbered in declaration order`() {
    #expect(Counter.fields.count.identity.positions == [0])
    #expect(Counter.fields.name.identity.positions == [1])
    #expect(Counter.fields.tags.identity.positions == [2])
}

@Test
func `a constant keeps its position and a computed or static property takes none`() {
    #expect(Mixed.fields.value.identity.positions == [1])
    #expect(Mixed.fields.observed.identity.positions == [2])
    #expect(Mixed.fields.changes.identity.positions == [3])
}

@Test
func `a property with an attribute gets no field and keeps its position`() {
    var wrapped = Wrapped()
    Wrapped.fields.after.set(&wrapped, to: 2)
    #expect(wrapped.after == 2)
    #expect(Wrapped.fields.before.identity.positions == [0])
    #expect(Wrapped.fields.after.identity.positions == [2])
}

@Test
func `a change through a field runs the property's observers once`() {
    var mixed = Mixed(id: 1)
    Mixed.fields.observed.set(&mixed, to: 5)
    #expect(mixed.observed == 5)
    #expect(mixed.changes == 1)
}

@Test
func `derived fields compose across types`() {
    let isOn = Outer.fields.inner.appending(Inner.fields.isOn)
    var outer = Outer()
    isOn.modify(&outer) { $0.toggle() }
    #expect(outer.inner.isOn)
    #expect(isOn.identity.positions == [1, 0])
}

@Test
func `a generic struct derives a field for its parameter`() {
    var box = Box(value: 1)
    Box<Int>.fields.value.modify(&box) { $0 += 41 }
    #expect(box.value == 42)
}

@Test
func `a public struct derives public fields`() {
    var counter = Tally()
    Tally.fields.count.set(&counter, to: 3)
    #expect(counter.count == 3)
}

@Test
func `generic code takes a part as a function of the namespace`() {
    var counter = Counter()
    write(&counter, { $0.count }, to: 7)
    write(&counter, { $0.name }, to: "Blob")
    #expect(read(counter) { $0.count } == 7)
    #expect(read(counter) { $0.name } == "Blob")
}

@Test
func `a derived field's lens sets through a copy`() {
    let counter = Counter()
    let changed = Counter.fields.count.lens.set(counter, 9)
    #expect(counter.count == 0)
    #expect(changed.count == 9)
}
