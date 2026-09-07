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

private struct ScopedToken: ~Escapable {
    let value: Int
}

private enum Choice<Value>: Equatable where Value: Equatable {
    case value(Value)
    case empty
}

private func requireCopyable<Value: Copyable>(_: Value) {}
private func requireEscapable<Value: Escapable>(_: Value) {}

@Suite
private struct `Folds preserve borrowed focus visits through weakening and composition` {
    let value = Optic<LinearChoice, LinearChoice, Token, Token>.Fold { source, visit in
        switch source {
        case let .value(token):
            visit(token)
            return true
        case .other:
            return false
        }
    }

    let copyableValue = Optic<Choice<Int>, Choice<Int>, Int, Int>.Prism(
        match: {
            switch $0 {
            case let .value(value): .right(value)
            case .empty: .left(.empty)
            }
        },
        embed: Choice<Int>.value
    )

    @Test
    func `a noncopyable source is visited without being consumed`() {
        let source = LinearChoice.value(Token(value: 4))
        var seen = 0
        let visited = value(source) { token in seen = token.value }
        let visitedAgain = value(source) { token in seen += token.value }
        let other = LinearChoice.other(Token(value: 5))
        let missed = value(other) { _ in seen = -1 }

        #expect(visited)
        #expect(visitedAgain)
        #expect(!missed)
        #expect(seen == 8)
        let sourceMatches = value.matches(source)
        let otherMatches = value.matches(other)
        #expect(sourceMatches)
        #expect(!otherMatches)
        requireCopyable(value)
        requireEscapable(value)
    }

    @Test
    func `a prism weakens to a fold that agrees with its match`() {
        let fold = Optic<Choice<Int>, Choice<Int>, Int, Int>.Fold(copyableValue)

        #expect(fold.extract(.value(6)) == 6)
        #expect(fold.extract(.empty) == nil)
        #expect(fold.matches(.value(1)))
        #expect(!fold.matches(.empty))
        for source in [Choice<Int>.value(2), .empty] {
            let matched: Int? = switch copyableValue.match(source) {
            case let .right(focus): focus
            case .left: nil
            }
            #expect(fold.extract(source) == matched)
        }
    }

    @Test
    func `a lens and an affine weaken to folds`() {
        let lens = Optic<Choice<Int>, Choice<Int>, Choice<Int>, Choice<Int>>.Lens.identity
        let affine = Optic<Choice<Int>, Choice<Int>, Int, Int>.Affine(copyableValue)

        #expect(Optic<Choice<Int>, Choice<Int>, Choice<Int>, Choice<Int>>.Fold(lens).extract(.empty) == .empty)
        #expect(Optic<Choice<Int>, Choice<Int>, Int, Int>.Fold(affine).extract(.value(3)) == 3)
        #expect(Optic<Choice<Int>, Choice<Int>, Int, Int>.Fold(affine).extract(.empty) == nil)
    }

    @Test
    func `folds compose through borrowed focuses`() {
        let inner = Optic<Token, Token, Int, Int>.Fold { token, visit in
            visit(token.value)
            return true
        }
        let composed = value >>> inner
        let identity = Optic<LinearChoice, LinearChoice, LinearChoice, LinearChoice>.Fold.identity >>> value

        #expect(composed.extract(.value(Token(value: 9))) == 9)
        #expect(composed.extract(.other(Token(value: 9))) == nil)
        let identityMatches = identity.matches(.value(Token(value: 1)))
        let identityMisses = identity.matches(.other(Token(value: 1)))
        #expect(identityMatches)
        #expect(!identityMisses)
    }

    @Test
    func `a nonescapable focus is lent to the visitor`() {
        let fold = Optic<Int, Int, ScopedToken, ScopedToken>.Fold { source, visit in
            visit(ScopedToken(value: source))
            return true
        }
        var seen = 0
        let visited = fold(7) { token in seen = token.value }

        #expect(visited)
        #expect(seen == 7)
    }
}
