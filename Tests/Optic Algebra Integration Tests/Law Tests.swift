import Pair
import Optic_Algebra_Integration
import Lens_Macro
import Isomorphism_Macro
import Prism_Macro
import Algebra_Test_Support
import Testing
@Lenses @Isomorphism private struct Count: Equatable { let value: Int }
@Prisms private enum Choice: Equatable { case none; case value(Int) }
@Test func lensAndIsomorphismLawsTransportTheChosenAlgebra() {
    let values = [-2, 0, 3].map { Count(value: $0) }
    let lens = Count.lenses.value
    for value in values {
        #expect(lens.set(value, lens.get(value)) == value)
        for replacement in [-1, 2] {
            #expect(lens.get(lens.set(value, replacement)) == replacement)
            #expect(lens.set(lens.set(value, replacement), 7) == lens.set(value, 7))
        }
    }
    let iso = Count.isomorphisms.memberwise
    #expect(Algebra.Law.Equation.check("record round trip", over: values, lhs: { iso.backward(iso.forward($0)) }, rhs: { $0 }) == nil)
    #expect(Algebra.Law.Equation.check("product round trip", over: [-2, 0, 3], lhs: { iso.forward(iso.backward($0)) }, rhs: { $0 }) == nil)
    let monoid = iso.transporting(Algebra.Monoid<Int>(identity: 0, combining: +))
    #expect(monoid.combining(Count(value: 2), Count(value: 3)).value == 5)
}
@Test func namedIsomorphismsReuseExistingProductsAndSums() {
    let distribute: Optic<Pair<Int, Either<String, Bool>>, Pair<Int, Either<String, Bool>>, Either<Pair<Int, String>, Pair<Int, Bool>>, Either<Pair<Int, String>, Pair<Int, Bool>>>.Isomorphism = AlgebraicIsomorphisms.distributivity()
    for source in [Pair(2, Either<String, Bool>.left("x")), Pair(3, .right(true))] {
        let rebuilt = distribute.backward(distribute.forward(source))
        #expect(rebuilt.first == source.first)
        #expect(rebuilt.second == source.second)
    }
    let associating: Optic<Pair<Pair<Int, String>, Bool>, Pair<Pair<Int, String>, Bool>, Pair<Int, Pair<String, Bool>>, Pair<Int, Pair<String, Bool>>>.Isomorphism = AlgebraicIsomorphisms.productAssociativity()
    let source = Pair(Pair(1, "x"), true)
    let rebuilt = associating.backward(associating.forward(source))
    #expect(rebuilt.first.first == 1 && rebuilt.first.second == "x" && rebuilt.second)
    let unit: Optic<Pair<Void, Int>, Pair<Void, Int>, Int, Int>.Isomorphism = AlgebraicIsomorphisms.leftUnit()
    #expect(unit.forward(unit.backward(42)) == 42)
}
@Test func prismAndAffineRebuildPreserveCases() {
    let prism = Choice.prisms.value
    for value in [Choice.none, .value(1), .value(2)] {
        switch prism.match(value) {
        case .left(let remainder): #expect(remainder == value)
        case .right(let focus): #expect(prism.embed(focus) == value)
        }
    }
    for n in [-1, 0, 3] {
        switch prism.match(prism.embed(n)) {
        case .right(let value): #expect(value == n)
        case .left: Issue.record("Prism injection must match")
        }
    }
}

@Test func sumUnitsAndAssociativityRoundTripBothDirections() {
    let zero: Optic<Either<Never, Int>, Either<Never, Int>, Int, Int>.Isomorphism = AlgebraicIsomorphisms.leftZero()
    #expect(zero.forward(zero.backward(42)) == 42)
    let iso: Optic<Either<Either<Int, String>, Bool>, Either<Either<Int, String>, Bool>, Either<Int, Either<String, Bool>>, Either<Int, Either<String, Bool>>>.Isomorphism = AlgebraicIsomorphisms.sumAssociativity()
    let sources: [Either<Either<Int, String>, Bool>] = [.left(.left(1)), .left(.right("x")), .right(true)]
    for value in sources { #expect(iso.backward(iso.forward(value)) == value) }
    let targets: [Either<Int, Either<String, Bool>>] = [.left(1), .right(.left("x")), .right(.right(true))]
    for value in targets { #expect(iso.forward(iso.backward(value)) == value) }
}
@Test func traversalIdentityCompositionAndReconstructionArity() {
    let traversal = Optic<[Int], [Int], Int, Int>.Traversal.each
    let samples = [[], [1], [1, 2, 3]]
    for source in samples {
        #expect(traversal.map(source, { $0 }).elementsEqual(source))
        #expect(traversal.map(traversal.map(source, { $0 + 1 }), { $0 * 2 }).elementsEqual(traversal.map(source, { ($0 + 1) * 2 })))
        let bazaar = traversal.decompose(source)
        #expect(bazaar.focuses.count == source.count)
        #expect(bazaar.reconstruct(source).elementsEqual(source))
    }
}
