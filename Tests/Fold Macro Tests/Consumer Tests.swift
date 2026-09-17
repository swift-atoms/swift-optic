import Fold_Macro
import Testing

@Folds
private enum Choice {
    case none
    case name(String)
    case pair(Int, String)
    case labeled(code: Int, note: String)
}

private struct LinearToken: ~Copyable {
    let value: Int
}

@Folds
private enum Linear: ~Copyable {
    case token(LinearToken)
    case empty
}

@Test
func `derived folds visit their own case and reject the others`() {
    #expect(Choice.folds.none.matches(.none))
    #expect(!Choice.folds.none.matches(.name("Blob")))
    #expect(Choice.folds.name.extract(.name("Blob")) == "Blob")
    #expect(Choice.folds.name.extract(.none) == nil)

    var pair: (Int, String)? = nil
    let visited = Choice.folds.pair(.pair(42, "Blob")) { pair = $0 }
    #expect(visited)
    #expect(pair?.0 == 42)
    #expect(pair?.1 == "Blob")

    var labeled: (code: Int, note: String)? = nil
    _ = Choice.folds.labeled(.labeled(code: 7, note: "seven")) { labeled = $0 }
    #expect(labeled?.code == 7)
    #expect(labeled?.note == "seven")
}

@Test
func `derived fold lends a noncopyable payload without consuming its source`() {
    let source = Linear.token(LinearToken(value: 3))
    var seen = 0
    let visited = Linear.folds.token(source) { seen += $0.value }
    let visitedAgain = Linear.folds.token(source) { seen += $0.value }
    let missed = Linear.folds.empty(source) { _ in seen = -1 }

    #expect(visited)
    #expect(visitedAgain)
    #expect(!missed)
    #expect(seen == 6)
    let emptyMatches = Linear.folds.empty.matches(.empty)
    #expect(emptyMatches)
}
