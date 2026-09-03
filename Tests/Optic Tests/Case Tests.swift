import Either
import Optic
import Testing

private struct Token: ~Copyable {
    let value: Int
}

private enum LinearChoice: ~Copyable {
    case value(Token)
    case other(Token)
}

private enum Choice<Value>: Equatable where Value: Equatable {
    case value(Value)
    case empty
}

@Suite
private struct `Case Tests` {
    let linear = Optic<LinearChoice, LinearChoice, Token, Token>.Case(
        prism: .init(
            match: { source in
                switch consume source {
                case let .value(token): .right(token)
                case let .other(token): .left(.other(token))
                }
            },
            embed: { token in .value(token) }
        ),
        fold: .init { source, visit in
            switch source {
            case let .value(token):
                visit(token)
                return true
            case .other:
                return false
            }
        }
    )

    @Test
    func `a case borrows through its fold and consumes through its prism`() {
        let source = LinearChoice.value(Token(value: 4))
        var seen = 0
        let visited = linear.visit(source) { seen = $0.value }
        let matches = linear.matches(source)
        let matched = linear.match(source)

        #expect(visited)
        #expect(matches)
        #expect(seen == 4)
        switch consume matched {
        case let .right(token): #expect(token.value == 4)
        case .left: Issue.record("expected the value case")
        }
    }

    @Test
    func `a copyable case derives its fold from its prism`() {
        let value = Optic<Choice<Int>, Choice<Int>, Int, Int>.Case(
            .init(
                match: {
                    switch $0 {
                    case let .value(value): .right(value)
                    case .empty: .left(.empty)
                    }
                },
                embed: Choice<Int>.value
            )
        )

        #expect(value.fold.extract(.value(6)) == 6)
        #expect(value.fold.extract(.empty) == nil)
        #expect(value.embed(7) == .value(7))
    }
}
