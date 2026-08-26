import Testing

@testable import Optic

extension Optic {
    @Suite struct Tests {
        @Test func `namespace is available`() {

            #expect(Bool(true))
        }
    }
}
