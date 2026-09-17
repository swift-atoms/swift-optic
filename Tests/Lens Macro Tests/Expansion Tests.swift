import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import Lens_Macro_Plugin

private let lensMacros: [String: MacroSpec] = [
  "Lenses": MacroSpec(type: Lens_Macro_Plugin.Macro.self)
]

@Test
func `lens derivation diagnoses a custom initializer`() {
  assertMacroExpansion(
    """
    @Lenses
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
          "@Lenses requires the synthesized memberwise initializer; structs with custom initializers must define their lenses explicitly.",
        line: 1,
        column: 1
      )
    ],
    macroSpecs: lensMacros,
    failureHandler: { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  )
}

@Test
func `lens derivation diagnoses an inferred stored property type`() {
  assertMacroExpansion(
    """
    @Lenses
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
        message: "@Lenses requires stored property `count` to have an explicit type annotation.",
        line: 1,
        column: 1
      )
    ],
    macroSpecs: lensMacros,
    failureHandler: { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  )
}

@Test
func `lens derivation diagnoses initialized constant storage`() {
  assertMacroExpansion(
    """
    @Lenses
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
          "@Lenses does not support initialized constant `number` because it is not a memberwise initializer parameter.",
        line: 1,
        column: 1
      )
    ],
    macroSpecs: lensMacros,
    failureHandler: { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  )
}
