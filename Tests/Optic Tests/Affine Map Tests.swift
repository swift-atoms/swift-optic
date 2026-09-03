import Either
import Optic
import Testing

private enum AffineChoice<Value>: Equatable where Value: Equatable {
    case value(Value)
    case empty
}

@Suite
private struct `Affine Map Tests` {
    let traversal = Optic<
        AffineChoice<Int>,
        AffineChoice<String>,
        Int,
        String
    >.Affine(
        decompose: {
            switch $0 {
            case let .value(value):
                .right((focus: value, reconstruct: AffineChoice<String>.value))
            case .empty:
                .left(.empty)
            }
        }
    )

    @Test
    func `matching source transforms its focus and target`() {
        #expect(traversal.map(.value(1)) { "\($0 + 1)" } == .value("2"))
    }

    @Test
    func `nonmatching source supplies its transformed target`() {
        #expect(traversal.map(.empty) { "\($0)" } == .empty)
    }
}
