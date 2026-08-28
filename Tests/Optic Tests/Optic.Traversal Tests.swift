import Testing

@testable import Optic

@Suite("TestTraversal")
@MainActor
struct TraversalTests {

    @Test
    func `get extracts all focused values`() {
        let each: TestTraversal<[Int], Int> = .each

        #expect(each.get([1, 2, 3]) == [1, 2, 3])
        #expect(each.get([]) == [])
    }

    @Test
    func `modify transforms all focused values`() {
        let each: TestTraversal<[Int], Int> = .each

        let result = each.modify([1, 2, 3]) { $0 * 2 }
        #expect(result == [2, 4, 6])
    }

    @Test
    func `composing chains two traversals`() {
        let outerEach: TestTraversal<[[Int]], [Int]> = .each
        let innerEach: TestTraversal<[Int], Int> = .each

        let composed = TestTraversal.composing(outerEach, innerEach)

        let nested = [[1, 2], [3, 4, 5]]
        #expect(composed.get(nested) == [1, 2, 3, 4, 5])

        let result = composed.modify(nested) { $0 * 10 }
        #expect(result == [[10, 20], [30, 40, 50]])
    }

    @Test
    func `appending chains traversals`() {
        let outerEach: TestTraversal<[[Int]], [Int]> = .each
        let innerEach: TestTraversal<[Int], Int> = .each

        let composed = outerEach.appending(innerEach)

        let nested = [[1, 2], [3, 4, 5]]
        #expect(composed.get(nested) == [1, 2, 3, 4, 5])

        let result = composed.modify(nested) { $0 * 10 }
        #expect(result == [[10, 20], [30, 40, 50]])
    }

    @Test
    func `identity focuses on the single whole value`() {
        let id: TestTraversal<Int, Int> = .identity

        #expect(id.get(42) == [42])
        #expect(id.modify(42) { $0 * 2 } == 84)
    }

    @Test
    func `set sets all focused values to the same value`() {
        let each: TestTraversal<[Int], Int> = .each

        let result = each.set([1, 2, 3], 99)
        #expect(result == [99, 99, 99])
    }

    @Test
    func `count returns number of focused elements`() {
        let each: TestTraversal<[Int], Int> = .each

        #expect(each.count([1, 2, 3]) == 3)
        #expect(each.count([]) == 0)
    }

    @Test
    func `isEmpty returns true when no focused elements`() {
        let each: TestTraversal<[Int], Int> = .each

        #expect(each.isEmpty([1, 2, 3]) == false)
        #expect(each.isEmpty([]) == true)
    }

    @Test
    func `each focuses on all array elements`() {
        let each: TestTraversal<[String], String> = .each

        #expect(each.get(["a", "b", "c"]) == ["a", "b", "c"])
        #expect(each.modify(["a", "b", "c"]) { $0.uppercased() } == ["A", "B", "C"])
    }

    @Test
    func `init from Affine`() {
        let firstAffine = TestAffine<[Int], Int>(
            extract: { $0.first },
            set: { array, value in
                guard !array.isEmpty else { return array }
                var copy = array
                copy[0] = value
                return copy
            }
        )

        let traversal = TestTraversal(firstAffine)

        #expect(traversal.get([1, 2, 3]) == [1])
        #expect(traversal.get([]) == [])
        #expect(traversal.modify([1, 2, 3]) { $0 * 10 } == [10, 2, 3])
    }

    @Test
    func `init from Lens`() {
        struct Point: Equatable, Sendable {
            var x: Int
            var y: Int
        }

        let xLens = TestLens<Point, Int>(
            get: { $0.x },
            set: { Point(x: $1, y: $0.y) }
        )

        let traversal = TestTraversal(xLens)

        let point = Point(x: 10, y: 20)
        #expect(traversal.get(point) == [10])
        #expect(traversal.modify(point) { $0 * 2 } == Point(x: 20, y: 20))
    }

    @Test
    func `init from Prism`() {
        let somePrism = TestPrism<Int?, Int>(
            embed: { $0 },
            extract: { $0 }
        )

        let traversal = TestTraversal(somePrism)

        #expect(traversal.get(42) == [42])
        #expect(traversal.get(nil) == [])
        #expect(traversal.modify(42) { $0 * 2 } == 84)
        #expect(traversal.modify(nil) { $0 * 2 } == nil)
    }

    @Test
    func `init from Isomorphism`() {
        let iso = TestIsomorphism<[Int], [Int]>(
            forward: { $0.reversed() },
            backward: { $0.reversed() }
        )

        let traversal = TestTraversal(iso)

        #expect(traversal.get([1, 2, 3]) == [[3, 2, 1]])

        #expect(traversal.modify([1, 2, 3]) { $0.map { $0 * 2 } } == [2, 4, 6])
    }

    @Test
    func `nested array modification`() {
        struct Document: Equatable, Sendable {
            var sections: [[String]]
        }

        let sectionsLens = TestLens<Document, [[String]]>(
            get: { $0.sections },
            set: { Document(sections: $1) }
        )

        let outerEach: TestTraversal<[[String]], [String]> = .each
        let innerEach: TestTraversal<[String], String> = .each

        let allWords = TestTraversal(sectionsLens)
            .appending(outerEach)
            .appending(innerEach)

        let doc = Document(sections: [["hello", "world"], ["foo", "bar"]])

        #expect(allWords.get(doc) == ["hello", "world", "foo", "bar"])

        let uppercased = allWords.modify(doc) { $0.uppercased() }
        #expect(uppercased.sections == [["HELLO", "WORLD"], ["FOO", "BAR"]])
    }
}
