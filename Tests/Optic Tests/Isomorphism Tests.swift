import Optic
import Testing

private struct IsomorphismBox<Value: Equatable>: Equatable {
    var value: Value
}

@Suite
struct `Isomorphism families obey inverse laws and support polymorphic mapping` {
    let isomorphism = Optic<(Int, Int), (Int, Int), String, String>.Isomorphism(
        forward: { "\($0.0):\($0.1)" },
        backward: { value in
            let separator = value.firstIndex(of: ":")!
            return (
                Int(value[..<separator])!,
                Int(value[value.index(after: separator)...])!
            )
        }
    )

    @Test
    func `reusable law suite validates both inverse equations`() {
        let box = Optic<
            IsomorphismBox<Int>,
            IsomorphismBox<Int>,
            Int,
            Int
        >.Isomorphism(
            forward: { $0.value },
            backward: { IsomorphismBox(value: $0) }
        )
        expectIsomorphismLaws(
            box,
            whole: IsomorphismBox(value: 2),
            part: 3
        )
    }

    @Test
    func `backward after forward is identity`() {
        let original = (2, 3)
        let roundTrip = isomorphism.backward(isomorphism.forward(original))
        #expect(roundTrip.0 == original.0)
        #expect(roundTrip.1 == original.1)
    }

    @Test
    func `forward after backward is identity`() {
        let original = "2:3"
        #expect(isomorphism.forward(isomorphism.backward(original)) == original)
    }

    @Test
    func `polymorphic family changes both focus and structure`() {
        let isomorphism = Optic<
            IsomorphismBox<Int>,
            IsomorphismBox<String>,
            Int,
            String
        >.Isomorphism(
            forward: { $0.value },
            backward: { IsomorphismBox(value: $0) }
        )

        #expect(isomorphism.forward(IsomorphismBox(value: 42)) == 42)
        #expect(isomorphism.backward("forty-two") == IsomorphismBox(value: "forty-two"))
    }
}
