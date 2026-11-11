import Testing

@testable import Optic

@Suite
struct `Fields change a stored part in place and can be told apart` {

    struct Address: Equatable, Sendable {
        var city: String
        var zip: String
    }

    struct Person: Equatable, Sendable {
        var name: String
        var address: Address
    }

    let name = Optic<Person, Person, String, String>.Field(
        0,
        get: { $0.name },
        modify: { whole, transform in transform(&whole.name) }
    )
    let address = Optic<Person, Person, Address, Address>.Field(
        1,
        get: { $0.address },
        modify: { whole, transform in transform(&whole.address) }
    )
    let city = Optic<Address, Address, String, String>.Field(
        0,
        get: { $0.city },
        modify: { whole, transform in transform(&whole.city) }
    )
    let person = Person(name: "Blob", address: Address(city: "Utrecht", zip: "3511"))

    @Test
    func `reading after a change gives the changed part`() {
        var changed = person
        name.modify(&changed) { $0 = "Blob Jr." }
        #expect(name.get(changed) == "Blob Jr.")
    }

    @Test
    func `a change that does nothing leaves the whole as it was`() {
        var changed = person
        name.modify(&changed) { _ in }
        #expect(changed == person)
    }

    @Test
    func `of two changes the last one wins`() {
        var twice = person
        name.set(&twice, to: "First")
        name.set(&twice, to: "Second")
        var once = person
        name.set(&once, to: "Second")
        #expect(twice == once)
    }

    @Test
    func `a change touches only its own part`() {
        var changed = person
        name.set(&changed, to: "Blob Jr.")
        #expect(changed.address == person.address)
    }

    @Test
    func `a field's identity is its position`() {
        #expect(name.identity == .init(0))
        #expect(address.identity == .init(1))
        #expect(name.identity != address.identity)
        #expect(name.identity.positions == [0])
    }

    @Test
    func `a composed field reads and changes the inner part and appends the positions`() {
        let personCity = address.appending(city)
        var changed = person
        personCity.modify(&changed) { $0 += " Centrum" }
        #expect(personCity.get(person) == "Utrecht")
        #expect(changed.address.city == "Utrecht Centrum")
        #expect(changed.address.zip == person.address.zip)
        #expect(changed.name == person.name)
        #expect(personCity.identity.positions == [1, 0])
        #expect(personCity.identity == address.identity.appending(city.identity))
    }

    @Test
    func `a field's lens is the same part and obeys the lens laws`() {
        let lens = name.lens
        #expect(lens.get(person) == name.get(person))
        #expect(lens.get(lens.set(person, "Blob Jr.")) == "Blob Jr.")
        #expect(lens.set(person, lens.get(person)) == person)
        #expect(lens.set(lens.set(person, "First"), "Second") == lens.set(person, "Second"))
    }

    @Test
    func `setting through the lens leaves the original whole unchanged`() {
        let changed = name.lens.set(person, "Blob Jr.")
        #expect(person.name == "Blob")
        #expect(changed.name == "Blob Jr.")
    }
}
