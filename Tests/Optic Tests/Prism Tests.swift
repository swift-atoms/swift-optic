import Either
import Optic
import Testing

private enum Choice<Value>: Equatable where Value: Equatable {
    case value(Value)
    case empty
}

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

private enum ScopedChoice: ~Escapable {
    case value(ScopedToken)
    case other(ScopedToken)
}

private enum Observation: Equatable {
    case value(Int)
    case other(Int)
}

private func observe(
    _ result: consuming Either<LinearChoice, Token>
) -> Observation {
    switch consume result {
    case let .right(token):
        .value(token.value)
    case let .left(choice):
        switch consume choice {
        case let .value(token): .value(token.value)
        case let .other(token): .other(token.value)
        }
    }
}

private func requireCopyable<Value: Copyable>(_: Value) {}
private func requireEscapable<Value: Escapable>(_: Value) {}

@Suite
private struct `Prism Tests` {
    let prism = Optic<Choice<Int>, Choice<String>, Int, String>.Prism(
        match: {
            switch $0 {
            case let .value(value): .right(value)
            case .empty: .left(.empty)
            }
        },
        embed: Choice<String>.value
    )

    @Test
    func `reusable law suite validates matching and embedding`() {
        let prism = Optic<Choice<Int>, Choice<Int>, Int, Int>.Prism(
            match: {
                switch $0 {
                case let .value(value): .right(value)
                case .empty: .left(.empty)
                }
            },
            embed: Choice<Int>.value
        )

        expectPrismLaws(prism, whole: .value(42), part: 42)
        expectPrismLaws(prism, whole: .empty, part: 42)
    }

    @Test
    func `matching a focus preserves its source value`() {
        guard case let .right(value) = prism.match(.value(2)) else {
            Issue.record("Expected a matching focus")
            return
        }
        #expect(value == 2)
    }

    @Test
    func `embedding a replacement constructs the target`() {
        #expect(prism.embed("two") == Choice<String>.value("two"))
    }

    @Test
    func `nonmatching source reconstructs the transformed target`() {
        guard case let .left(target) = prism.match(.empty) else {
            Issue.record("Expected a reconstructed target")
            return
        }
        #expect(target == Choice<String>.empty)
    }

    @Test
    func `matching after embedding is identity`() {
        let prism = Optic<Choice<Int>, Choice<Int>, Int, Int>.Prism(
            match: {
                switch $0 {
                case let .value(value): .right(value)
                case .empty: .left(.empty)
                }
            },
            embed: Choice<Int>.value
        )

        guard case let .right(value) = prism.match(prism.embed(42)) else {
            Issue.record("Expected an embedded value to match")
            return
        }
        #expect(value == 42)
    }

    @Test
    func `embedding after a successful match is identity`() {
        let prism = Optic<Choice<Int>, Choice<Int>, Int, Int>.Prism(
            match: {
                switch $0 {
                case let .value(value): .right(value)
                case .empty: .left(.empty)
                }
            },
            embed: Choice<Int>.value
        )
        let source = Choice.value(42)

        guard case let .right(value) = prism.match(source) else {
            Issue.record("Expected the source to match")
            return
        }
        #expect(prism.embed(value) == source)
    }

    @Test
    func `noncopyable source is consumed into either branch`() {
        let prism = Optic<LinearChoice, LinearChoice, Token, Token>.Prism(
            match: { source in
                switch consume source {
                case let .value(token): .right(token)
                case let .other(token): .left(.other(token))
                }
            },
            embed: { token in .value(token) }
        )

        #expect(
            observe(prism.match(.value(Token(value: 1)))) == .value(1)
        )
        #expect(
            observe(prism.match(.other(Token(value: 2)))) == .other(2)
        )
        #expect(
            observe(.left(prism.embed(Token(value: 3)))) == .value(3)
        )
        requireEscapable(prism)
    }

    @Test
    func `nonescapable input sorts are consumed into escapable result sorts`() {
        let prism = Optic<
            ScopedChoice,
            Observation,
            Int,
            ScopedToken
        >.Prism(
            match: { source in
                switch source {
                case let .value(token): .right(token.value)
                case let .other(token): .left(.other(token.value))
                }
            },
            embed: { token in .value(token.value) }
        )

        switch prism.match(.value(ScopedToken(value: 1))) {
        case let .right(value): #expect(value == 1)
        case .left: Issue.record("Expected the scoped source to match")
        }
        switch prism.match(.other(ScopedToken(value: 2))) {
        case .right: Issue.record("Expected the scoped source not to match")
        case let .left(value): #expect(value == .other(2))
        }
        #expect(prism.embed(ScopedToken(value: 3)) == .value(3))
        requireCopyable(prism)
        requireEscapable(prism)
    }

}
