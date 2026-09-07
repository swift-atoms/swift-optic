import Testing

@testable import Optic

@Suite
@MainActor
struct `Setters transform focuses while preserving setter laws and composition` {

    struct User: Equatable, Sendable {
        var name: String
        var age: Int
    }

    static let nameSetter = TestSetter<User, String>(
        modify: { user, f in User(name: f(user.name), age: user.age) }
    )

    static let ageSetter = TestSetter<User, Int>(
        modify: { user, f in User(name: user.name, age: f(user.age)) }
    )

    static let eachInArray = TestSetter<[Int], Int>(
        modify: { array, f in array.map(f) }
    )

    @Suite struct `Setters modify and replace focused values` {}
    @Suite struct `Setters preserve array shape across empty single and multiple elements` {}
    @Suite struct `Setter conversions preserve the source optic focus behavior` {}
    @Suite struct `Setters obey identity and composition laws` {}
    @Suite struct `Composed setters update nested focuses` {}
}

@MainActor
extension `Setters transform focuses while preserving setter laws and composition`.`Setters modify and replace focused values` {

    @Test
    func `over applies transform to focused part`() {
        let alice = `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 30)
        let upper = `Setters transform focuses while preserving setter laws and composition`.nameSetter.over(alice) { $0.uppercased() }
        #expect(upper == `Setters transform focuses while preserving setter laws and composition`.User(name: "ALICE", age: 30))
    }

    @Test
    func `set replaces focused part with constant`() {
        let alice = `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 30)
        let bob = `Setters transform focuses while preserving setter laws and composition`.nameSetter.set(alice, to: "Bob")
        #expect(bob == `Setters transform focuses while preserving setter laws and composition`.User(name: "Bob", age: 30))
    }

    @Test
    func `over with inout mutates in place`() {
        var alice = `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 30)
        `Setters transform focuses while preserving setter laws and composition`.nameSetter.over(&alice) { $0.uppercased() }
        #expect(alice == `Setters transform focuses while preserving setter laws and composition`.User(name: "ALICE", age: 30))
    }

    @Test
    func `set with inout mutates in place`() {
        var alice = `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 30)
        `Setters transform focuses while preserving setter laws and composition`.ageSetter.set(&alice, to: 99)
        #expect(alice == `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 99))
    }
}

@MainActor
extension `Setters transform focuses while preserving setter laws and composition`.`Setters preserve array shape across empty single and multiple elements` {

    @Test
    func `setter on empty array is identity-shape`() {
        let result = `Setters transform focuses while preserving setter laws and composition`.eachInArray.over([]) { $0 + 1 }
        #expect(result == [])
    }

    @Test
    func `setter on multi-element array transforms each`() {
        let result = `Setters transform focuses while preserving setter laws and composition`.eachInArray.over([1, 2, 3]) { $0 * 10 }
        #expect(result == [10, 20, 30])
    }

    @Test
    func `setter on single-element behaves like singleton transform`() {
        let result = `Setters transform focuses while preserving setter laws and composition`.eachInArray.over([42]) { $0 - 42 }
        #expect(result == [0])
    }
}

@MainActor
extension `Setters transform focuses while preserving setter laws and composition`.`Setters obey identity and composition laws` {

    @Test
    func `identity law: over with id is identity`() {

        let alice = `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 30)
        #expect(`Setters transform focuses while preserving setter laws and composition`.nameSetter.over(alice) { $0 } == alice)
        #expect(`Setters transform focuses while preserving setter laws and composition`.ageSetter.over(alice) { $0 } == alice)

        let array = [1, 2, 3]
        #expect(`Setters transform focuses while preserving setter laws and composition`.eachInArray.over(array) { $0 } == array)
    }

    @Test
    func `composition law: sequential over equals composed transform`() {

        let alice = `Setters transform focuses while preserving setter laws and composition`.User(name: "alice", age: 30)
        let f: @Sendable (String) -> String = { $0.uppercased() }
        let g: @Sendable (String) -> String = { $0 + "!" }

        let sequential = `Setters transform focuses while preserving setter laws and composition`.nameSetter.over(`Setters transform focuses while preserving setter laws and composition`.nameSetter.over(alice, f), g)
        let composed = `Setters transform focuses while preserving setter laws and composition`.nameSetter.over(alice) { g(f($0)) }
        #expect(sequential == composed)
    }

    @Test
    func `The identity setter applies its transformation to the whole value`() {
        let identity = TestSetter<Int, Int>.identity
        #expect(identity.over(42) { $0 + 1 } == 43)
        #expect(identity.over(42) { $0 } == 42)
    }
}

@MainActor
extension `Setters transform focuses while preserving setter laws and composition`.`Setter conversions preserve the source optic focus behavior` {

    @Test
    func `Setter constructed from Lens behaves equivalently`() {
        let nameLens = TestLens<`Setters transform focuses while preserving setter laws and composition`.User, String>(
            get: { $0.name },
            set: { `Setters transform focuses while preserving setter laws and composition`.User(name: $1, age: $0.age) }
        )
        let setter = TestSetter(nameLens)
        let alice = `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 30)
        #expect(
            setter.over(alice) { $0.lowercased() } == nameLens.modify(alice) { $0.lowercased() }
        )
    }

    @Test
    func `Setter constructed from Isomorphism preserves transformation`() {
        let mirror = TestIsomorphism<Int, Int>(
            forward: { -$0 },
            backward: { -$0 }
        )
        let setter = TestSetter(mirror)

        #expect(setter.over(7) { $0 + 1 } == 6)
    }

    @Test
    func `Setter constructed from Prism applies only when extract succeeds`() {
        enum Either: Equatable, Sendable {
            case left(Int)
            case right(String)
        }
        let leftPrism = TestPrism<Either, Int>(
            embed: { .left($0) },
            extract: {
                guard case .left(let v) = $0 else { return nil }
                return v
            }
        )
        let setter = TestSetter(leftPrism)
        #expect(setter.over(.left(5)) { $0 + 1 } == .left(6))
        #expect(setter.over(.right("hi")) { $0 + 1 } == .right("hi"))
    }

    @Test
    func `Setter constructed from Traversal applies to all elements`() {
        let each = TestTraversal<[Int], Int>(
            get: { $0 },
            modify: { array, f in array.map(f) }
        )
        let setter = TestSetter(each)
        #expect(setter.over([1, 2, 3]) { $0 * 2 } == [2, 4, 6])
    }
}

@MainActor
extension `Setters transform focuses while preserving setter laws and composition`.`Composed setters update nested focuses` {

    @Test
    func `Setter composes with Setter via appending`() {
        struct Outer: Equatable, Sendable {
            var users: [`Setters transform focuses while preserving setter laws and composition`.User]
        }

        let usersSetter = TestSetter<Outer, [`Setters transform focuses while preserving setter laws and composition`.User]>(
            modify: { outer, f in Outer(users: f(outer.users)) }
        )
        let eachUser = TestSetter<[`Setters transform focuses while preserving setter laws and composition`.User], `Setters transform focuses while preserving setter laws and composition`.User>(
            modify: { array, f in array.map(f) }
        )

        let composed = usersSetter.appending(eachUser)
        let outer = Outer(users: [
            `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 30),
            `Setters transform focuses while preserving setter laws and composition`.User(name: "Bob", age: 25),
        ])
        let aged = composed.over(outer) { user in
            `Setters transform focuses while preserving setter laws and composition`.User(name: user.name, age: user.age + 1)
        }
        #expect(
            aged
                == Outer(users: [
                    `Setters transform focuses while preserving setter laws and composition`.User(name: "Alice", age: 31),
                    `Setters transform focuses while preserving setter laws and composition`.User(name: "Bob", age: 26),
                ])
        )
    }

    @Test
    func `Setter composes with Setter via operator`() {
        struct Outer: Equatable, Sendable {
            var inner: Inner
        }
        struct Inner: Equatable, Sendable {
            var value: Int
        }

        let innerSetter = TestSetter<Outer, Inner>(
            modify: { outer, f in Outer(inner: f(outer.inner)) }
        )
        let valueSetter = TestSetter<Inner, Int>(
            modify: { inner, f in Inner(value: f(inner.value)) }
        )
        let composed = innerSetter >>> valueSetter

        let outer = Outer(inner: Inner(value: 10))
        #expect(composed.over(outer) { $0 * 2 } == Outer(inner: Inner(value: 20)))
    }

    @Test
    func `Lens composed with Setter via operator yields Setter`() {
        struct Outer: Equatable, Sendable {
            var inner: Int
        }
        let innerLens = TestLens<Outer, Int>(
            get: { $0.inner },
            set: { Outer(inner: $1) }
        )
        let doublingSetter = TestSetter<Int, Int>(
            modify: { value, f in f(value) }
        )
        let composed: TestSetter<Outer, Int> = innerLens >>> doublingSetter
        #expect(composed.over(Outer(inner: 5)) { $0 * 2 } == Outer(inner: 10))
    }
}
