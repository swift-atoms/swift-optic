import Either
import Optic
import Testing
import Traversal_Affine_Macro

@Affine
private enum Result {
    case value(Int)
    case failure(String)
}

@Affine
private enum GenericResult<Value> {
    case value(Value)
    case empty
}

@Test
func `derived affine traversal updates only its matching case`() {
    let traversal = Result.affine.value

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
    let traversal = GenericResult<Int>.affine.value(to: String.self)

    guard case .value("42") = traversal.map(.value(42), { "\($0)" }) else {
        Issue.record("Expected a transformed target value")
        return
    }
    guard case .empty = traversal.map(.empty, { "\($0)" }) else {
        Issue.record("Expected empty to reconstruct in the target family")
        return
    }
}
