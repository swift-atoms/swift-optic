import Testing

@testable import Optic

@Suite
@MainActor
struct `Isomorphisms preserve values through inverse transformations and composition` {

    @Test
    func `forward transforms Whole to Part`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        #expect(iso.forward(42) == "42")
        #expect(iso.forward(0) == "0")
        #expect(iso.forward(-1) == "-1")
    }

    @Test
    func `backward transforms Part to Whole`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        #expect(iso.backward("42") == 42)
        #expect(iso.backward("0") == 0)
        #expect(iso.backward("-1") == -1)
    }

    @Test
    func `Applying an isomorphism forward then backward restores each whole value`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        for value in [0, 1, -1, 42, 100, -999] {
            #expect(iso.backward(iso.forward(value)) == value)
        }
    }

    @Test
    func `Applying an isomorphism backward then forward restores each part value`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        for value in ["0", "1", "-1", "42", "100", "-999"] {
            #expect(iso.forward(iso.backward(value)) == value)
        }
    }

    @Test
    func `reversed swaps forward and backward`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        let reversed = iso.reversed

        #expect(reversed.forward("42") == 42)
        #expect(reversed.backward(42) == "42")
    }

    @Test
    func `composing chains two isos`() {
        let intToString = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        let stringToArray = TestIsomorphism<String, [Character]>(
            forward: { Array($0) },
            backward: { String($0) }
        )

        let composed = TestIsomorphism.composing(intToString, stringToArray)

        #expect(composed.forward(42) == ["4", "2"])
        #expect(composed.backward(["4", "2"]) == 42)
    }

    @Test
    func `appending chains isos`() {
        let intToString = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )

        let stringToArray = TestIsomorphism<String, [Character]>(
            forward: { Array($0) },
            backward: { String($0) }
        )

        let composed = intToString.appending(stringToArray)

        #expect(composed.forward(42) == ["4", "2"])
        #expect(composed.backward(["4", "2"]) == 42)
    }

    @Test
    func `identity passes values through unchanged`() {
        let id: TestIsomorphism<Int, Int> = .identity

        #expect(id.forward(42) == 42)
        #expect(id.backward(42) == 42)
    }

    @Test
    func `modify applies transformation via iso`() {
        let iso = TestIsomorphism<[Int], [Int]>(
            forward: { $0.reversed() },
            backward: { $0.reversed() }
        )

        let result = iso.modify([1, 2, 3]) { $0.map { $0 * 2 } }
        #expect(result == [2, 4, 6])
    }

    @Test
    func `An isomorphism updates the original value through its transformed representation`() {
        let iso = TestIsomorphism<[Int], [Int]>(
            forward: { $0.reversed() },
            backward: { $0.reversed() }
        )

        var value = [1, 2, 3]
        iso.modify(&value) { $0.map { $0 * 2 } }

        #expect(value == [2, 4, 6])
    }
}

@Suite
struct `Isomorphism extraction and embedding apply inverse transformations` {
    @Test
    func `forward transforms value`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        #expect(iso.forward(42) == "42")
    }

    @Test
    func `backward transforms value`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        #expect(iso.backward("42") == 42)
    }

    @Test
    func `The isomorphism restores a value after forward and backward conversion`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let original = 42
        let result = iso.backward(iso.forward(original))
        #expect(result == original)
    }

    @Test
    func `The isomorphism restores a value after backward and forward conversion`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let original = "42"
        let result = iso.forward(iso.backward(original))
        #expect(result == original)
    }
}

@Suite
struct `Reversing an isomorphism exchanges its transformations` {
    @Test
    func `reversed swaps forward and backward`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let reversed = iso.reversed

        #expect(reversed.forward("42") == 42)
        #expect(reversed.backward(42) == "42")
    }

    @Test
    func `double reversal equals original`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let doubleReversed = iso.reversed.reversed

        #expect(doubleReversed.forward(42) == iso.forward(42))
        #expect(doubleReversed.backward("42") == iso.backward("42"))
    }
}

@Suite
struct `Isomorphism composition chains forward and backward transformations` {
    @Test
    func `composing two isos forward works correctly`() {
        let intToString = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let stringToArray = TestIsomorphism<String, [Character]>(
            forward: { Array($0) },
            backward: { String($0) }
        )

        let composed = TestIsomorphism.composing(intToString, stringToArray)
        #expect(composed.forward(42) == ["4", "2"])
    }

    @Test
    func `composing two isos backward works correctly`() {
        let intToString = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let stringToArray = TestIsomorphism<String, [Character]>(
            forward: { Array($0) },
            backward: { String($0) }
        )

        let composed = TestIsomorphism.composing(intToString, stringToArray)
        #expect(composed.backward(["4", "2"]) == 42)
    }

    @Test
    func `appending is equivalent to composing`() {
        let intToString = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let stringToArray = TestIsomorphism<String, [Character]>(
            forward: { Array($0) },
            backward: { String($0) }
        )

        let composed = TestIsomorphism.composing(intToString, stringToArray)
        let appended = intToString.appending(stringToArray)

        #expect(composed.forward(42) == appended.forward(42))
        #expect(composed.backward(["4", "2"]) == appended.backward(["4", "2"]))
    }
}

@Suite
struct `Identity isomorphisms preserve values in both directions` {
    @Test
    func `identity forward returns same value`() {
        let iso = TestIsomorphism<Int, Int>.identity
        #expect(iso.forward(42) == 42)
    }

    @Test
    func `identity backward returns same value`() {
        let iso = TestIsomorphism<Int, Int>.identity
        #expect(iso.backward(42) == 42)
    }
}

@Suite
struct `Isomorphism modification updates values through their transformed representation` {
    @Test
    func `modify applies transformation via iso`() {
        let celsiusToFahrenheit = TestIsomorphism<Double, Double>(
            forward: { $0 * 9 / 5 + 32 },
            backward: { ($0 - 32) * 5 / 9 }
        )

        let result = celsiusToFahrenheit.modify(0) { $0 + 18 }
        #expect(result == 10)
    }

    @Test
    func `modify inout applies transformation in place`() {
        let iso = TestIsomorphism<Int, Int>(
            forward: { $0 * 2 },
            backward: { $0 / 2 }
        )

        var value = 10
        iso.modify(&value) { $0 + 4 }
        #expect(value == 12)
    }
}

@Suite
struct `Isomorphisms convert to lenses with equivalent extraction and replacement` {
    @Test
    func `lens from iso get equals forward`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let lens = TestLens(iso)

        #expect(lens.get(42) == "42")
    }

    @Test
    func `lens from iso set ignores original whole`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let lens = TestLens(iso)

        let result = lens.set(999, "42")
        #expect(result == 42)
    }
}

@Suite
struct `Isomorphisms convert to prisms that always match` {
    @Test
    func `prism from iso embed equals backward`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let prism = TestPrism(iso)

        #expect(prism.embed("42") == 42)
    }

    @Test
    func `prism from iso extract always succeeds`() {
        let iso = TestIsomorphism<Int, String>(
            forward: { String($0) },
            backward: { Int($0)! }
        )
        let prism = TestPrism(iso)

        #expect(prism.extract(42) == "42")
    }
}
