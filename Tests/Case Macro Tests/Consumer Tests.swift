import Case_Macro
import Testing

@Prisms
@Folds
@Cases
private enum Choice {
    case none
    case name(String)
    case pair(Int, String)
}

private struct LinearToken: ~Copyable {
    let value: Int
}

@Prisms
@Folds
@Cases
private enum Linear: ~Copyable {
    case token(LinearToken)
    case empty
}

@Test
func `a derived case pairs its prism with its fold`() {
    #expect(Choice.cases.name.matches(.name("Blob")))
    #expect(!Choice.cases.name.matches(.none))
    #expect(Choice.cases.none.matches(.none))

    var seen: String? = nil
    let visited = Choice.cases.name.visit(.name("Blob")) { seen = $0 }
    #expect(visited)
    #expect(seen == "Blob")

    switch Choice.cases.pair.match(.pair(1, "one")) {
    case let .right(pair):
        #expect(pair.0 == 1)
        #expect(pair.1 == "one")
    case .left:
        Issue.record("Expected the pair case to match")
    }
    #expect(Choice.cases.name.matches(Choice.cases.name.embed("Blob")))
}

@Test
func `a derived case lends a noncopyable payload and embeds one`() {
    var seen = 0
    let visited = Linear.cases.token.visit(.token(.init(value: 3))) { seen = $0.value }
    #expect(visited)
    #expect(seen == 3)
    let empty = Linear.cases.empty.matches(.empty)
    #expect(empty)
    let embedded = Linear.cases.token.embed(.init(value: 4))
    let matched = Linear.cases.token.matches(embedded)
    #expect(matched)
}
