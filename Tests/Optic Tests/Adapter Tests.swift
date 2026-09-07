import Either
import Optic
import Testing

private struct AdapterBox<Value: Equatable>: Equatable {
    var value: Value
}

private enum FirstFailure: Error, Equatable {
    case forward
    case backward
}

private enum SecondFailure: Error, Equatable {
    case forward
    case backward
}

private func fallibleForward(_ value: Int) throws(FirstFailure) -> String {
    guard value >= 0 else { throw .forward }
    return String(value)
}

private func fallibleBackward(_ value: Int) throws(SecondFailure) -> String {
    guard value >= 0 else { throw .backward }
    return String(value)
}

@Suite
private struct `Adapters preserve directional behavior and composition failure origins` {
    let adapter = Optic<AdapterBox<Int>, AdapterBox<String>, Int, String>.Adapter(
        forward: { $0.value },
        backward: { AdapterBox(value: $0) }
    )

    @Test
    func `forward reads the source focus`() {
        #expect(adapter.forward(AdapterBox(value: 42)) == 42)
    }

    @Test
    func `backward constructs the target from its replacement`() {
        #expect(adapter.backward("forty-two") == AdapterBox(value: "forty-two"))
    }

    @Test
    func `Never is inferred independently for total directions`() {
        let total = Optic<Int, Int, String, String>.Adapter(
            forward: String.init,
            backward: { Int($0)! }
        )
        let exact: Optic<Int, Int, String, String>.Adapter<Never, Never> = total

        #expect(exact.forward(42) == "42")
        #expect(exact.backward("42") == 42)
    }

    @Test
    func `one directional failure does not pollute the total direction`() throws {
        let forwardOnly = Optic<Int, Int, String, String>.Adapter(
            forward: fallibleForward,
            backward: { Int($0)! }
        )
        let backwardOnly = Optic<String, String, Int, Int>.Adapter(
            forward: { Int($0)! },
            backward: fallibleBackward
        )
        let exactForward:
            Optic<Int, Int, String, String>.Adapter<FirstFailure, Never> =
                forwardOnly
        let exactBackward:
            Optic<String, String, Int, Int>.Adapter<Never, SecondFailure> =
                backwardOnly

        #expect(try exactForward.forward(42) == "42")
        #expect(exactForward.backward("42") == 42)
        #expect(exactBackward.forward("42") == 42)
        #expect(try exactBackward.backward(42) == "42")
    }

    @Test
    func `Adapter composition normalizes Never on both axes`() throws {
        let first = Optic<Int, Int, String, String>.Adapter(
            forward: String.init,
            backward: { Int($0)! }
        )
        let second = Optic<String, String, Int, Int>.Adapter(
            forward: { value throws(SecondFailure) in
                guard let value = Int(value) else { throw .forward }
                return value
            },
            backward: { String($0) }
        )
        let composed:
            Optic<Int, Int, Int, Int>.Adapter<SecondFailure, Never> =
                first >>> second

        #expect(try composed.forward(42) == 42)
        #expect(composed.backward(42) == 42)
    }

    @Test
    func `Adapter composition tags failures by optic origin`() {
        let first = Optic<Int, Int, String, String>
            .Adapter<FirstFailure, FirstFailure>(
                forward: { value throws(FirstFailure) in
                    guard value >= 0 else { throw FirstFailure.forward }
                    return String(value)
                },
                backward: { value throws(FirstFailure) in
                    guard value != "first" else { throw FirstFailure.backward }
                    return Int(value)!
                }
            )
        let second = Optic<String, String, Double, String>
            .Adapter<SecondFailure, SecondFailure>(
                forward: { value throws(SecondFailure) in
                    guard value != "second" else { throw SecondFailure.forward }
                    return Double(value)!
                },
                backward: { value throws(SecondFailure) in
                    guard value != "second" else { throw SecondFailure.backward }
                    return value
                }
            )
        let composed: Optic<Int, Int, Double, String>.Adapter<
            Either<FirstFailure, SecondFailure>,
            Either<FirstFailure, SecondFailure>
        > = first >>> second

        do {
            _ = try composed.forward(-1)
            Issue.record("Expected the first forward arrow to fail")
        } catch {
            guard case .left(.forward) = error else {
                Issue.record("Expected a first-origin forward failure")
                return
            }
        }
        do {
            _ = try composed.forward(0)
        } catch {
            Issue.record("Expected a successful composed forward arrow: \(error)")
        }
        do {
            _ = try composed.backward("second")
            Issue.record("Expected the second backward arrow to fail")
        } catch {
            guard case .right(.backward) = error else {
                Issue.record("Expected a second-origin backward failure")
                return
            }
        }
        do {
            _ = try composed.backward("first")
            Issue.record("Expected the first backward arrow to fail")
        } catch {
            guard case .left(.backward) = error else {
                Issue.record("Expected a first-origin backward failure")
                return
            }
        }
    }

    @Test
    func `Isomorphism weakens and composes without adding failures`() throws {
        let isomorphism = Optic<Int, Int, String, String>.Isomorphism(
            forward: String.init,
            backward: { Int($0)! }
        )
        let adapter:
            Optic<Int, Int, String, String>.Adapter<Never, Never> =
                isomorphism.adapter
        let fallible = Optic<String, String, Int, Int>.Adapter(
            forward: { value throws(SecondFailure) in
                guard let value = Int(value) else { throw .forward }
                return value
            },
            backward: { String($0) }
        )
        let composed:
            Optic<Int, Int, Int, Int>.Adapter<SecondFailure, Never> =
                isomorphism >>> fallible

        #expect(adapter.forward(42) == "42")
        #expect(try composed.forward(42) == 42)
        #expect(composed.backward(42) == 42)
    }
}
