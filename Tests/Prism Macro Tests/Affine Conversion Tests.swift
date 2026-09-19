import Either
import Optic
import Testing
import Prism_Macro

@Prisms
private enum AffineResult {
    case value(Int)
    case failure(String)
}

@Prisms
private enum GenericResult<Value> {
    case value(Value)
    case empty
}

@Test
func `derived affine traversal updates only its matching case`() {
    let traversal = AffineResult.prisms.value.asAffine()

    guard case let .right(context) = traversal.decompose(.value(21)) else {
        Issue.record("Expected value to match")
        return
    }
    #expect(context.focus == 21)
    guard case .left(.failure("no")) = traversal.decompose(.failure("no")) else {
        Issue.record("Expected failure to reconstruct through a value mismatch")
        return
    }

    guard case .value(42) = traversal.map(.value(21), { _ in 42 }) else {
        Issue.record("Expected updated value")
        return
    }
    guard case .failure("no") = traversal.map(.failure("no"), { _ in 42 }) else {
        Issue.record("Expected nonmatching case to remain unchanged")
        return
    }
}

@Test
func `derived affine traversal transforms a generic family`() {
    let traversal = GenericResult<Int>.prisms.value(to: String.self).asAffine()

    guard case .value("42") = traversal.map(.value(42), { "\($0)" }) else {
        Issue.record("Expected a transformed target value")
        return
    }
    guard case .empty = traversal.map(.empty, { "\($0)" }) else {
        Issue.record("Expected empty to reconstruct in the target family")
        return
    }
}
