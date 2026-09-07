import Optic
import Testing

private struct Person: Equatable {
    var name: String
    var age: Int
}

private struct Box<Value>: Equatable where Value: Equatable {
    var value: Value
}

@Suite
private struct `Lens families obey lens laws and support polymorphic mapping` {
    let lens = Optic<Person, Person, String, String>.Lens(
        decompose: { whole in
            (
                focus: whole.name,
                reconstruct: { replacement in
                    var target = whole
                    target.name = replacement
                    return target
                }
            )
        }
    )

    @Test
    func `setting the viewed part is identity`() {
        let person = Person(name: "Blob", age: 1)
        #expect(lens.set(person, lens.get(person)) == person)
    }

    @Test
    func `viewing after setting returns the new part`() {
        let person = Person(name: "Blob", age: 1)
        #expect(lens.get(lens.set(person, "Blob Jr.")) == "Blob Jr.")
    }

    @Test
    func `later setting supersedes earlier setting`() {
        let person = Person(name: "Blob", age: 1)
        let sequential = lens.set(lens.set(person, "First"), "Second")
        #expect(sequential == lens.set(person, "Second"))
    }

    @Test
    func `polymorphic lens changes focus and structure types`() {
        let lens = Optic<Box<Int>, Box<String>, Int, String>.Lens(
            decompose: { source in
                (
                    focus: source.value,
                    reconstruct: { Box<String>(value: $0) }
                )
            }
        )

        let source = Box(value: 42)
        #expect(lens.get(source) == 42)
        #expect(lens.set(source, "forty-two") == Box(value: "forty-two"))
    }
}
