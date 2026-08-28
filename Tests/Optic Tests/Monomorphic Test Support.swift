import Either
import Optic
import Testing

typealias TestIsomorphism<Whole, Part> = Optic<Whole, Whole, Part, Part>.Isomorphism
typealias TestLens<Whole, Part> = Optic<Whole, Whole, Part, Part>.Lens
typealias TestPrism<Whole, Part> = Optic<Whole, Whole, Part, Part>.Prism
typealias TestAffine<Whole, Part> = Optic<Whole, Whole, Part, Part>.Affine
typealias TestTraversal<Whole, Part> = Optic<Whole, Whole, Part, Part>.Traversal
typealias TestSetter<Whole, Part> = Optic<Whole, Whole, Part, Part>.Setter

func expectIsomorphismLaws<Whole: Equatable, Part: Equatable>(
    _ isomorphism: TestIsomorphism<Whole, Part>,
    whole: Whole,
    part: Part
) {
    #expect(
        isomorphism.backward(isomorphism.forward(whole)) == whole
    )
    #expect(
        isomorphism.forward(isomorphism.backward(part)) == part
    )
}

func expectPrismLaws<Whole: Equatable, Part: Equatable>(
    _ prism: TestPrism<Whole, Part>,
    whole: Whole,
    part: Part
) {
    guard case let .right(matched) = prism.match(prism.embed(part)) else {
        Issue.record("Expected an embedded focus to match")
        return
    }
    #expect(matched == part)

    switch prism.match(whole) {
    case let .left(unmatched):
        #expect(unmatched == whole)
    case let .right(matched):
        #expect(prism.embed(matched) == whole)
    }
}
