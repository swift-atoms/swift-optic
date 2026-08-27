import Testing

import Optic
import Optic_Standard_Library_Integration

enum TestError: Swift.Error, Hashable, Sendable {
    case test
    case other
}

@Suite
struct `Prism - Composition` {
    @Test
    func `composing two prisms embeds correctly`() {

        let optionalPrism = Result<Int, TestError>?.prisms.some
        let resultPrism = Result<Int, TestError>.prisms.success

        let composed = Optic.Prism.composing(optionalPrism, resultPrism)
        let result = composed.embed(42)
        #expect(result == .some(.success(42)))
    }

    @Test
    func `composing two prisms extracts correctly`() {
        let optionalPrism = Result<Int, TestError>?.prisms.some
        let resultPrism = Result<Int, TestError>.prisms.success

        let composed = Optic.Prism.composing(optionalPrism, resultPrism)
        let result = composed.extract(.some(.success(42)))
        #expect(result == 42)
    }

    @Test
    func `composing two prisms returns nil when outer fails`() {
        let optionalPrism = Result<Int, TestError>?.prisms.some
        let resultPrism = Result<Int, TestError>.prisms.success

        let composed = Optic.Prism.composing(optionalPrism, resultPrism)
        let result = composed.extract(nil)
        #expect(result == nil)
    }

    @Test
    func `composing two prisms returns nil when inner fails`() {
        let optionalPrism = Result<Int, TestError>?.prisms.some
        let resultPrism = Result<Int, TestError>.prisms.success

        let composed = Optic.Prism.composing(optionalPrism, resultPrism)
        let result = composed.extract(.some(.failure(.test)))
        #expect(result == nil)
    }

    @Test
    func `appending is equivalent to composing`() {
        let optionalPrism = Result<Int, TestError>?.prisms.some
        let resultPrism = Result<Int, TestError>.prisms.success

        let composed = Optic.Prism.composing(optionalPrism, resultPrism)
        let appended = optionalPrism.appending(resultPrism)

        let testValue: Result<Int, TestError>? = .some(.success(42))
        #expect(composed.extract(testValue) == appended.extract(testValue))
        #expect(composed.embed(42) == appended.embed(42))
    }
}

@Suite
struct `Optional - Prism` {
    @Test
    func `somePrism embed creates optional`() {
        let prism = Int?.prisms.some
        let result = prism.embed(42)
        #expect(result == .some(42))
    }

    @Test
    func `somePrism extract returns value from some`() {
        let prism = Int?.prisms.some
        let result = prism.extract(.some(42))
        #expect(result == 42)
    }

    @Test
    func `somePrism extract returns nil from none`() {
        let prism = Int?.prisms.some
        let result = prism.extract(nil)
        #expect(result == nil)
    }
}

@Suite
struct `Result - Prism` {
    @Test
    func `successPrism embed creates success result`() {
        let prism = Result<Int, TestError>.prisms.success
        let result = prism.embed(42)
        #expect(result == .success(42))
    }

    @Test
    func `successPrism extract returns value from success`() {
        let prism = Result<Int, TestError>.prisms.success
        let result = prism.extract(.success(42))
        #expect(result == 42)
    }

    @Test
    func `successPrism extract returns nil from failure`() {
        let prism = Result<Int, TestError>.prisms.success
        let result = prism.extract(.failure(.test))
        #expect(result == nil)
    }

    @Test
    func `failurePrism embed creates failure result`() {
        let prism = Result<Int, TestError>.prisms.failure
        let result = prism.embed(.test)
        #expect(result == .failure(.test))
    }

    @Test
    func `failurePrism extract returns error from failure`() {
        let prism = Result<Int, TestError>.prisms.failure
        let result = prism.extract(.failure(.test))
        #expect(result == .test)
    }

    @Test
    func `failurePrism extract returns nil from success`() {
        let prism = Result<Int, TestError>.prisms.failure
        let result = prism.extract(.success(42))
        #expect(result == nil)
    }
}
