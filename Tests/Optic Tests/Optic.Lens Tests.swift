import Testing

@testable import Optic

@Suite
@MainActor
struct `Lenses preserve focus laws through modification composition and conversion` {

    struct User: Equatable, Sendable {
        var name: String
        var age: Int
    }

    struct Address: Equatable, Sendable {
        var city: String
        var zip: String
    }

    struct Person: Equatable, Sendable {
        var user: User
        var address: Address
    }

    static let nameLens = TestLens<User, String>(
        get: { $0.name },
        set: { User(name: $1, age: $0.age) }
    )

    static let ageLens = TestLens<User, Int>(
        get: { $0.age },
        set: { User(name: $0.name, age: $1) }
    )

    static let userLens = TestLens<Person, User>(
        get: { $0.user },
        set: { Person(user: $1, address: $0.address) }
    )

    static let cityLens = TestLens<Address, String>(
        get: { $0.city },
        set: { Address(city: $1, zip: $0.zip) }
    )

    @Test
    func `get extracts Part from Whole`() {
        let user = User(name: "Alice", age: 30)
        #expect(Self.nameLens.get(user) == "Alice")
        #expect(Self.ageLens.get(user) == 30)
    }

    @Test
    func `set replaces Part in Whole`() {
        let user = User(name: "Alice", age: 30)
        let updated = Self.nameLens.set(user, "Bob")

        #expect(updated.name == "Bob")
        #expect(updated.age == 30)
    }

    @Test
    func `Reading a lens after replacement returns the new focus`() {
        let user = User(name: "Alice", age: 30)
        let newName = "Charlie"

        let result = Self.nameLens.get(Self.nameLens.set(user, newName))
        #expect(result == newName)
    }

    @Test
    func `Replacing a lens focus with its current value preserves the whole`() {
        let user = User(name: "Alice", age: 30)

        let result = Self.nameLens.set(user, Self.nameLens.get(user))
        #expect(result == user)
    }

    @Test
    func `A second lens replacement supersedes the first replacement`() {
        let user = User(name: "Alice", age: 30)

        let result1 = Self.nameLens.set(Self.nameLens.set(user, "Bob"), "Charlie")
        let result2 = Self.nameLens.set(user, "Charlie")

        #expect(result1 == result2)
    }

    @Test
    func `composing chains two lenses`() {
        let addressLens = TestLens<Person, Address>(
            get: { $0.address },
            set: { Person(user: $0.user, address: $1) }
        )

        let composed = TestLens.composing(addressLens, Self.cityLens)

        let person = Person(
            user: User(name: "Alice", age: 30),
            address: Address(city: "NYC", zip: "10001")
        )

        #expect(composed.get(person) == "NYC")

        let updated = composed.set(person, "LA")
        #expect(updated.address.city == "LA")
        #expect(updated.user == person.user)
    }

    @Test
    func `appending chains lenses`() {
        let composed = Self.userLens.appending(Self.nameLens)

        let person = Person(
            user: User(name: "Alice", age: 30),
            address: Address(city: "NYC", zip: "10001")
        )

        #expect(composed.get(person) == "Alice")

        let updated = composed.set(person, "Bob")
        #expect(updated.user.name == "Bob")
        #expect(updated.address == person.address)
    }

    @Test
    func `identity passes values through unchanged`() {
        let id: TestLens<Int, Int> = .identity

        #expect(id.get(42) == 42)
        #expect(id.set(42, 100) == 100)
    }

    @Test
    func `modify transforms the focused part`() {
        let user = User(name: "Alice", age: 30)
        let result = Self.ageLens.modify(user) { $0 + 1 }

        #expect(result.age == 31)
        #expect(result.name == "Alice")
    }

    @Test
    func `A lens updates its focus in place and preserves other fields`() {
        var user = User(name: "Alice", age: 30)
        Self.ageLens.modify(&user) { $0 + 1 }

        #expect(user.age == 31)
        #expect(user.name == "Alice")
    }

    @Test
    func `Lens construction preserves the source isomorphism focus behavior`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        let lens = TestLens(iso)

        #expect(lens.get(42) == "42")
        #expect(lens.set(42, "100") == 100)
    }
}

struct Point: Equatable, Sendable {
    var x: Int
    var y: Int
}

struct User: Equatable, Sendable {
    var name: String
    var age: Int
    var address: Address
}

struct Address: Equatable, Sendable {
    var street: String
    var city: String
}

extension Point {
    static var xLens: TestLens<Point, Int> {
        TestLens(
            get: { $0.x },
            set: { point, x in Point(x: x, y: point.y) }
        )
    }

    static var yLens: TestLens<Point, Int> {
        TestLens(
            get: { $0.y },
            set: { point, y in Point(x: point.x, y: y) }
        )
    }
}

extension User {
    static var nameLens: TestLens<User, String> {
        TestLens(
            get: { $0.name },
            set: { user, name in User(name: name, age: user.age, address: user.address) }
        )
    }

    static var ageLens: TestLens<User, Int> {
        TestLens(
            get: { $0.age },
            set: { user, age in User(name: user.name, age: age, address: user.address) }
        )
    }

    static var addressLens: TestLens<User, Address> {
        TestLens(
            get: { $0.address },
            set: { user, address in User(name: user.name, age: user.age, address: address) }
        )
    }
}

extension Address {
    static var streetLens: TestLens<Address, String> {
        TestLens(
            get: { $0.street },
            set: { address, street in Address(street: street, city: address.city) }
        )
    }

    static var cityLens: TestLens<Address, String> {
        TestLens(
            get: { $0.city },
            set: { address, city in Address(street: address.street, city: city) }
        )
    }
}

@Suite
struct `Lens extraction and replacement preserve the surrounding value` {
    @Test
    func `get extracts value`() {
        let point = Point(x: 10, y: 20)
        #expect(Point.xLens.get(point) == 10)
    }

    @Test
    func `set replaces value`() {
        let point = Point(x: 10, y: 20)
        let result = Point.xLens.set(point, 99)
        #expect(result == Point(x: 99, y: 20))
    }

    @Test
    func `set preserves other fields`() {
        let point = Point(x: 10, y: 20)
        let result = Point.xLens.set(point, 99)
        #expect(result.y == 20)
    }
}

@Suite
struct `Lens extraction and replacement obey get set laws` {
    @Test
    func `GetSet law: get after set returns the set value`() {
        let point = Point(x: 10, y: 20)
        let newX = 99
        let result = Point.xLens.get(Point.xLens.set(point, newX))
        #expect(result == newX)
    }

    @Test
    func `SetGet law: set with get value is identity`() {
        let point = Point(x: 10, y: 20)
        let result = Point.xLens.set(point, Point.xLens.get(point))
        #expect(result == point)
    }

    @Test
    func `SetSet law: second set wins`() {
        let point = Point(x: 10, y: 20)
        let first = 50
        let second = 99
        let result1 = Point.xLens.set(Point.xLens.set(point, first), second)
        let result2 = Point.xLens.set(point, second)
        #expect(result1 == result2)
    }
}

@Suite
struct `Lens composition focuses through nested values` {
    @Test
    func `composing two lenses get works correctly`() {
        let user = User(
            name: "Alice",
            age: 30,
            address: Address(street: "123 Main St", city: "Boston")
        )

        let streetLens = TestLens.composing(User.addressLens, Address.streetLens)
        #expect(streetLens.get(user) == "123 Main St")
    }

    @Test
    func `composing two lenses set works correctly`() {
        let user = User(
            name: "Alice",
            age: 30,
            address: Address(street: "123 Main St", city: "Boston")
        )

        let streetLens = TestLens.composing(User.addressLens, Address.streetLens)
        let result = streetLens.set(user, "456 Oak Ave")

        #expect(result.address.street == "456 Oak Ave")
        #expect(result.address.city == "Boston")
        #expect(result.name == "Alice")
    }

    @Test
    func `appending is equivalent to composing`() {
        let user = User(
            name: "Alice",
            age: 30,
            address: Address(street: "123 Main St", city: "Boston")
        )

        let composed = TestLens.composing(User.addressLens, Address.streetLens)
        let appended = User.addressLens.appending(Address.streetLens)

        #expect(composed.get(user) == appended.get(user))
        #expect(composed.set(user, "New Street") == appended.set(user, "New Street"))
    }
}

@Suite
struct `Identity lenses extract and replace whole values` {
    @Test
    func `identity get returns same value`() {
        let lens = TestLens<Int, Int>.identity
        #expect(lens.get(42) == 42)
    }

    @Test
    func `identity set ignores whole and returns part`() {
        let lens = TestLens<Int, Int>.identity
        #expect(lens.set(999, 42) == 42)
    }
}

@Suite
struct `Lens modification transforms the focused value` {
    @Test
    func `modify transforms focused value`() {
        let point = Point(x: 10, y: 20)
        let result = Point.xLens.modify(point) { $0 * 2 }
        #expect(result == Point(x: 20, y: 20))
    }

    @Test
    func `modify inout transforms in place`() {
        var point = Point(x: 10, y: 20)
        Point.xLens.modify(&point) { $0 * 2 }
        #expect(point == Point(x: 20, y: 20))
    }

    @Test
    func `modify preserves lens laws`() {
        let point = Point(x: 10, y: 20)
        let transform: (Int) -> Int = { $0 + 5 }

        let viaModify = Point.xLens.modify(point, transform)
        let viaGetSet = Point.xLens.set(point, transform(Point.xLens.get(point)))

        #expect(viaModify == viaGetSet)
    }
}

@Suite
struct `Lens construction preserves isomorphism transformations` {
    @Test
    func `lens from iso satisfies GetSet law`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let lens = TestLens(iso)

        let whole = 42
        let part = "99"
        let result = lens.get(lens.set(whole, part))
        #expect(result == part)
    }
}
