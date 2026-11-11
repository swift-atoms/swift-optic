import Testing

@testable import Optic

private enum Sample {
    struct Place: Equatable, Sendable {
        var city: String
        var zip: String
    }

    struct Resident: Equatable, Sendable {
        var name: String
        var address: Place
    }

    static var name: Optic<Resident, Resident, String, String>.Field {
        .init(
            identity: .init(positions: [0]),
            get: { $0.name },
            modify: { whole, transform in transform(&whole.name) }
        )
    }

    static var address: Optic<Resident, Resident, Place, Place>.Field {
        .init(
            identity: .init(positions: [1]),
            get: { $0.address },
            modify: { whole, transform in transform(&whole.address) }
        )
    }

    static var city: Optic<Place, Place, String, String>.Field {
        .init(
            identity: .init(positions: [0]),
            get: { $0.city },
            modify: { whole, transform in transform(&whole.city) }
        )
    }

    static let person = Resident(name: "Blob", address: Place(city: "Utrecht", zip: "3511"))
}

@Test
func `reading after a change gives the changed part`() {
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
    var changed = person
    name.modify(&changed) { $0 = "Blob Jr." }
    #expect(name.get(changed) == "Blob Jr.")
}

@Test
func `a change that does nothing leaves the whole as it was`() {
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
    var changed = person
    name.modify(&changed) { _ in }
    #expect(changed == person)
}

@Test
func `of two changes the last one wins`() {
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
    var twice = person
    name.set(&twice, to: "First")
    name.set(&twice, to: "Second")
    var once = person
    name.set(&once, to: "Second")
    #expect(twice == once)
}

@Test
func `a change touches only its own part`() {
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
    var changed = person
    name.set(&changed, to: "Blob Jr.")
    #expect(changed.address == person.address)
}

@Test
func `a field's identity is its position`() {
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
    #expect(name.identity == .init(positions: [0]))
    #expect(address.identity == .init(positions: [1]))
    #expect(name.identity != address.identity)
    #expect(name.identity.positions == [0])
}

@Test
func `a composed field reads and changes the inner part and appends the positions`() {
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
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
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
    let lens = name.lens
    #expect(lens.get(person) == name.get(person))
    #expect(lens.get(lens.set(person, "Blob Jr.")) == "Blob Jr.")
    #expect(lens.set(person, lens.get(person)) == person)
    #expect(lens.set(lens.set(person, "First"), "Second") == lens.set(person, "Second"))
}

@Test
func `setting through the lens leaves the original whole unchanged`() {
    let name = Sample.name
    let address = Sample.address
    let city = Sample.city
    let person = Sample.person
    _ = (name, address, city, person)
    let changed = name.lens.set(person, "Blob Jr.")
    #expect(person.name == "Blob")
    #expect(changed.name == "Blob Jr.")
}
