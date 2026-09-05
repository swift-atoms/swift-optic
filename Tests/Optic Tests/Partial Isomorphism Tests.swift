import Either
import Optic
import Testing

private enum FirstFailure: Error, Equatable {
    case forward
    case backward
}

private enum SecondFailure: Error, Equatable {
    case forward
    case backward
}

private struct Unique: ~Copyable {
    let value: Int
}

@Suite
private struct `Partial Isomorphism Tests` {
    let first = Optic<Int, Int, Int, Int>.Isomorphism.Partial(
        forward: { value throws(FirstFailure) in
            guard (0...10).contains(value) else { throw .forward }
            return value + 10
        },
        backward: { value throws(FirstFailure) in
            guard (10...20).contains(value) else { throw .backward }
            return value - 10
        }
    )

    let second = Optic<Int, Int, Int, Int>.Isomorphism.Partial(
        forward: { value throws(SecondFailure) in
            guard (15...25).contains(value) else { throw .forward }
            return value + 10
        },
        backward: { value throws(SecondFailure) in
            guard (25...35).contains(value) else { throw .backward }
            return value - 10
        }
    )

    @Test(arguments: Array(0...10))
    func `successful directions obey both inverse laws`(value: Int) throws {
        #expect(try first.backward(first.forward(value)) == value)
        #expect(try first.forward(first.backward(value + 10)) == value + 10)
    }

    @Test(arguments: Array(5...10))
    func `composition restricts the supported domain and preserves inverses`(value: Int) throws {
        let composed = first.appending(second)
        #expect(try composed.forward(value) == value + 20)
        #expect(try composed.backward(composed.forward(value)) == value)
        #expect(try composed.forward(composed.backward(value + 20)) == value + 20)
    }

    @Test
    func `composition retains failure origin in each direction`() {
        let composed = first.appending(second)
        #expect(throws: Either<FirstFailure, SecondFailure>.left(.forward)) {
            try composed.forward(-1)
        }
        #expect(throws: Either<FirstFailure, SecondFailure>.right(.forward)) {
            try composed.forward(2)
        }
        #expect(throws: Either<FirstFailure, SecondFailure>.right(.backward)) {
            try composed.backward(36)
        }
        #expect(throws: Either<FirstFailure, SecondFailure>.left(.backward)) {
            try composed.backward(31)
        }
    }

    @Test
    func `reversal exchanges directions and failure types`() throws {
        let asymmetric = Optic<Int, Int, Int, Int>.Isomorphism.Partial(
            forward: first.forward,
            backward: { value throws(SecondFailure) in
                guard (10...20).contains(value) else { throw .backward }
                return value - 10
            }
        )
        let reversed: Optic<Int, Int, Int, Int>.Isomorphism.Partial<SecondFailure, FirstFailure> =
            asymmetric.reversed
        #expect(try reversed.forward(15) == 5)
        #expect(try reversed.backward(5) == 15)
        #expect(try reversed.reversed.forward(5) == first.forward(5))
        #expect(throws: SecondFailure.backward) { try reversed.forward(0) }
        #expect(throws: FirstFailure.forward) { try reversed.backward(20) }
    }

    @Test
    func `total composition preserves exact failure types`() throws {
        let identity = Optic<Int, Int, Int, Int>.Isomorphism.identity
        let left: Optic<Int, Int, Int, Int>.Isomorphism.Partial<FirstFailure, FirstFailure> =
            identity.partial.appending(first)
        let right: Optic<Int, Int, Int, Int>.Isomorphism.Partial<FirstFailure, FirstFailure> =
            first.appending(identity.partial)
        let total: Optic<Int, Int, Int, Int>.Isomorphism.Partial<Never, Never> =
            identity.partial.appending(identity.partial)
        let totalLeft: Optic<Int, Int, Int, Int>.Isomorphism.Partial<FirstFailure, FirstFailure> =
            identity.appending(first)
        let totalRight: Optic<Int, Int, Int, Int>.Isomorphism.Partial<FirstFailure, FirstFailure> =
            first.appending(identity)
        #expect(try left.forward(5) == 15)
        #expect(try right.backward(15) == 5)
        #expect(total.forward(5) == 5)
        #expect(try totalLeft.forward(5) == 15)
        #expect(try totalRight.backward(15) == 5)
    }

    @Test
    func `weakening exposes the same directional transformations`() throws {
        let adapter: Optic<Int, Int, Int, Int>.Adapter<FirstFailure, FirstFailure> = first.adapter
        #expect(try adapter.forward(5) == first.forward(5))
        #expect(try adapter.backward(15) == first.backward(15))
    }

    @Test
    func `noncopyable representations retain ownership through composition`() {
        let unwrap = Optic<Unique, Unique, Int, Int>.Isomorphism.Partial(
            forward: { (value: consuming Unique) in value.value },
            backward: { Unique(value: $0) }
        )
        let composed = unwrap.appending(unwrap.reversed)
        let result = composed.forward(Unique(value: 42))
        #expect(result.value == 42)
    }
}
