import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import Isomorphism_Macro_Plugin

private let isomorphismMacros: [String: MacroSpec] = [
  "Isomorphism": MacroSpec(type: Isomorphism_Macro_Plugin.Macro.self)
]

@Test
func `isomorphism derivation diagnoses a custom initializer`() {
  assertMacroExpansion(
    """
    @Isomorphism
    struct User {
        var name: String

        init(name: String) {
            self.name = name.trimmingCharacters(in: .whitespaces)
        }
    }
    """,
    expandedSource: """
      struct User {
          var name: String

          init(name: String) {
              self.name = name.trimmingCharacters(in: .whitespaces)
          }
      }
      """,
    diagnostics: [
      DiagnosticSpec(
        message:
          "@Isomorphism requires the synthesized memberwise initializer; structs with custom initializers must define their isomorphism explicitly.",
        line: 1,
        column: 1
      )
    ],
    macroSpecs: isomorphismMacros,
    failureHandler: { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  )
}

@Test
func `isomorphism derivation diagnoses an inferred stored property type`() {
  assertMacroExpansion(
    """
    @Isomorphism
    struct Counter {
        var count = 0
    }
    """,
    expandedSource: """
      struct Counter {
          var count = 0
      }
      """,
    diagnostics: [
      DiagnosticSpec(
        message:
          "@Isomorphism requires stored property `count` to have an explicit type annotation.",
        line: 1,
        column: 1
      )
    ],
    macroSpecs: isomorphismMacros,
    failureHandler: { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  )
}

@Test
func `isomorphism derivation diagnoses initialized constant storage`() {
  assertMacroExpansion(
    """
    @Isomorphism
    struct Version {
        let number: Int = 1
    }
    """,
    expandedSource: """
      struct Version {
          let number: Int = 1
      }
      """,
    diagnostics: [
      DiagnosticSpec(
        message:
          "@Isomorphism does not support initialized constant `number` because it is not a memberwise initializer parameter.",
        line: 1,
        column: 1
      )
    ],
    macroSpecs: isomorphismMacros,
    failureHandler: { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  )
}
