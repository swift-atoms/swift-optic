import Either
import Optic
import Testing

private struct Person: Equatable {
    var name: String
    var route: Route
}

@dynamicMemberLookup
private enum Route: Equatable {
    case home
    case user(Int)
}

private enum Status: Int, Equatable {
    case accepted = 202
}

extension Route: Optic<Route, Route, Route, Route>.Prism.Accessible {
    struct Prisms {
        var home: Optic<Route, Route, Void, Void>.Prism {
            .init(
                match: {
                    switch $0 {
                    case .home: return .right(())
                    case let .user(id): return .left(.user(id))
                    }
                },
                embed: { _ in .home }
            )
        }

        var user: Optic<Route, Route, Int, Int>.Prism {
            .init(
                match: {
                    switch $0 {
                    case .home: return .left(.home)
                    case let .user(id): return .right(id)
                    }
                },
                embed: Route.user
            )
        }
    }

    static var prisms: Prisms { .init() }
}

@Suite
private struct `Optic convenience operations preserve composition and focus behavior` {
    let name = Optic<Person, Person, String, String>.Lens { person in
        (
            focus: person.name,
            reconstruct: { replacement in
                var person = person
                person.name = replacement
                return person
            }
        )
    }

    let route = Optic<Person, Person, Route, Route>.Lens { person in
        (
            focus: person.route,
            reconstruct: { replacement in
                var person = person
                person.route = replacement
                return person
            }
        )
    }

    @Test
    func `isomorphisms reverse and compose with the operator`() {
        let text = Optic<Int, Int, String, String>.Isomorphism(
            forward: String.init,
            backward: { Int($0)! }
        )
        let count = Optic<String, String, Int, Int>.Isomorphism(
            forward: { $0.count },
            backward: { String(repeating: "x", count: $0) }
        )
        let composed = text >>> count

        #expect(composed.forward(123) == 3)
        #expect(text.reversed.forward("42") == 42)
    }

    @Test
    func `String owns its Substring isomorphism`() {
        let isomorphism = String.isomorphisms.substring
        let source = "swift"[...]

        #expect(isomorphism.forward(source) == "swift")
        #expect(isomorphism.backward("optic") == "optic"[...])
        #expect(
            isomorphism.backward(isomorphism.forward(source)) == source
        )
    }

    @Test
    func `RawRepresentable owns a value-preserving raw prism`() {
        let prism = Status.prisms.rawValue

        guard case .right(.accepted) = prism.match(202) else {
            Issue.record("Expected a represented raw value to match")
            return
        }
        guard case .left(404) = prism.match(404) else {
            Issue.record("Expected an invalid raw value to remain available")
            return
        }
        #expect(prism.embed(.accepted) == 202)
    }

    @Test
    func `fixed Prism preserves mismatches`() {
        let prism = Optic<Int, Int, Void, Void>.Prism.fixed(42)

        guard case .right = prism.match(42) else {
            Issue.record("Expected the fixed value to match")
            return
        }
        guard case .left(7) = prism.match(7) else {
            Issue.record("Expected the mismatch to remain available")
            return
        }
        #expect(prism.embed(()) == 42)
    }

    @Test
    func `lens convenience modifies without weakening its representation`() {
        var person = Person(name: "Blob", route: .home)

        name.modify(&person) { $0 + " Jr." }

        #expect(person.name == "Blob Jr.")
        #expect(name.set(person, "Blob III").name == "Blob III")
    }

    @Test
    func `dynamic prism access retains pattern and extraction syntax`() {
        let root = Optic<Route, Route, Route, Route>.Prism.identity
        let user = root.user

        #expect(user.matches(.user(42)))
        #expect(user.extract(.user(42)) == 42)
        #expect(user ~= Route.user(42))
        #expect(!(user ~= Route.home))
    }

    @Test
    func `instance dynamic members use the existing prism extraction`() {
        let source = Route.user(42)
        let value: Int? = source.user
        #expect(value == 42)
        #expect(source.user == Route.prisms.user.extract(source))
        #expect(Route.home.user == nil)
        #expect(Route.home.home != nil)

        func apply(_ source: Route, extract: (Route) -> Int?) -> Int? {
            extract(source)
        }
        #expect(apply(source, extract: \.user) == 42)
        #expect(apply(.home, extract: \.user) == nil)
    }

    @Test
    func `optional and result prisms preserve unmatched sources`() {
        let some = Optional<Int>.prisms.some
        let success = Swift.Result<Int, TestFailure>.prisms.success

        #expect(some.extract(.some(42)) == 42)
        guard case .left(.none) = some.match(.none) else {
            Issue.record("Expected nil to remain an unmatched source")
            return
        }
        #expect(success.extract(.success(42)) == 42)
        guard case .left(.failure(.expected)) = success.match(.failure(.expected)) else {
            Issue.record("Expected a failure to remain an unmatched result")
            return
        }
    }

    @Test
    func `lens and prism compose to an affine optic`() {
        let user = route >>> Route.prisms.user
        let person = Person(name: "Blob", route: .user(1))

        #expect(user.extract(person) == 1)
        #expect(user.modify(person) { $0 + 1 }.route == .user(2))
    }

    @Test
    func `polymorphic each traversal changes array element type`() {
        let each = Optic<[Int], [String], Int, String>.Traversal.each

        #expect(each.map([1, 2, 3], String.init) == ["1", "2", "3"])
    }

    @Test
    func `traversal composition reconstructs nested cardinalities`() {
        let outer = Optic<[[Int]], [[String]], [Int], [String]>.Traversal.each
        let inner = Optic<[Int], [String], Int, String>.Traversal.each
        let each = outer >>> inner

        #expect(each.map([[1, 2], [], [3]]) { "v=\($0)" } == [["v=1", "v=2"], [], ["v=3"]])
    }

    @Test
    func `setter conversion keeps concise update syntax`() {
        let setter = Optic<Person, Person, String, String>.Setter(name)
        let person = Person(name: "Blob", route: .home)

        #expect(setter.set(person, to: "New").name == "New")
        #expect(setter.over(person) { $0.uppercased() }.name == "BLOB")
    }
}

private enum TestFailure: Error, Equatable {
    case expected
}
