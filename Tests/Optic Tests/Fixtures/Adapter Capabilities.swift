import Either
import Optic

enum FirstForward: Error { case failed }
enum FirstBackward: Error { case failed }
enum SecondForward: Error { case failed }
enum SecondBackward: Error { case failed }

func firstForward(_ value: Int) throws(FirstForward) -> String {
    guard value >= 0 else { throw .failed }
    return String(value)
}

func firstBackward(_ value: String) throws(FirstBackward) -> Int {
    guard let value = Int(value) else { throw .failed }
    return value
}

func secondForward(_ value: String) throws(SecondForward) -> Double {
    guard let value = Double(value) else { throw .failed }
    return value
}

func secondBackward(_ value: Double) throws(SecondBackward) -> String {
    String(value)
}

struct Scoped: ~Copyable, ~Escapable {
    let value: Int
}

struct Linear: ~Copyable {
    let value: Int
}

func proveAdapterCapabilities() throws {
    let total = Optic<Int, Int, String, String>.Adapter(
        forward: String.init,
        backward: { Int($0)! }
    )
    let totalExact:
        Optic<Int, Int, String, String>.Adapter<Never, Never> = total
    let totalForward: String = totalExact.forward(42)
    let totalBackward: Int = totalExact.backward("42")
    _ = (totalForward, totalBackward)

    let forwardOnly = Optic<Int, Int, String, String>.Adapter(
        forward: firstForward,
        backward: { Int($0)! }
    )
    let forwardExact:
        Optic<Int, Int, String, String>.Adapter<FirstForward, Never> =
            forwardOnly
    let forwardValue: String = try forwardExact.forward(42)
    let backwardValue: Int = forwardExact.backward("42")
    _ = (forwardValue, backwardValue)

    let backwardOnly = Optic<Int, Int, String, String>.Adapter(
        forward: String.init,
        backward: firstBackward
    )
    let backwardExact:
        Optic<Int, Int, String, String>.Adapter<Never, FirstBackward> =
            backwardOnly
    let totalValue: String = backwardExact.forward(42)
    let fallibleValue: Int = try backwardExact.backward("42")
    _ = (totalValue, fallibleValue)

    let independent = Optic<Int, Int, String, String>.Adapter(
        forward: firstForward,
        backward: firstBackward
    )
    let independentExact:
        Optic<Int, Int, String, String>
            .Adapter<FirstForward, FirstBackward> = independent
    _ = independentExact

    let second = Optic<String, String, Double, Double>.Adapter(
        forward: secondForward,
        backward: secondBackward
    )
    let composed: Optic<Int, Int, Double, Double>.Adapter<
        Either<FirstForward, SecondForward>,
        Either<FirstBackward, SecondBackward>
    > = independent >>> second
    _ = composed

    let normalizedForward:
        Optic<Int, Int, Double, Double>.Adapter<SecondForward, SecondBackward> =
            total >>> second
    let normalizedBackward:
        Optic<Int, Int, String, String>.Adapter<FirstForward, FirstBackward> =
            independent >>> Optic<String, String, String, String>.Isomorphism.identity
    _ = (normalizedForward, normalizedBackward)

    let linear = Optic<Scoped, Linear, Linear, Scoped>.Adapter(
        forward: { Linear(value: $0.value) },
        backward: { Linear(value: $0.value) }
    )
    let linearExact:
        Optic<Scoped, Linear, Linear, Scoped>.Adapter<Never, Never> = linear
    _ = linearExact.forward(Scoped(value: 1))
    _ = linearExact.backward(Scoped(value: 2))

    let isomorphism = Optic<Scoped, Linear, Int, String>.Isomorphism(
        forward: { $0.value },
        backward: { Linear(value: $0.count) }
    )
    let prism = Optic<Int, String, Double, Scoped>.Prism(
        match: { .right(Double($0)) },
        embed: { String($0.value) }
    )
    let isomorphismThenPrism:
        Optic<Scoped, Linear, Double, Scoped>.Prism = isomorphism >>> prism
    _ = isomorphismThenPrism

    let firstPrism = Optic<Scoped, Linear, Int, String>.Prism(
        match: { .right($0.value) },
        embed: { Linear(value: $0.count) }
    )
    let secondIsomorphism = Optic<Int, String, Double, Scoped>.Isomorphism(
        forward: Double.init,
        backward: { String($0.value) }
    )
    let prismThenIsomorphism:
        Optic<Scoped, Linear, Double, Scoped>.Prism =
            firstPrism >>> secondIsomorphism
    _ = prismThenIsomorphism

    let reversed:
        Optic<Scoped, Int, Linear, Scoped>.Isomorphism =
            Optic<Scoped, Linear, Int, Scoped>.Isomorphism(
                forward: { $0.value },
                backward: { Linear(value: $0.value) }
            ).reversed
    _ = reversed
}
