import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import Field_Macro_Plugin

private let fieldMacros: [String: MacroSpec] = [
    "Fields": MacroSpec(type: Field_Macro_Plugin::Macro.self)
]

@Test
func `field derivation numbers stored variables and skips what is not stored`() {
    assertMacroExpansion(
        """
        @Fields
        struct Counter {
            static let format = "v1"
            let id: Int
            var count = 0
            var doubled: Int { count * 2 }
        }
        """,
        expandedSource: """
            struct Counter {
                static let format = "v1"
                let id: Int
                var count = 0
                var doubled: Int { count * 2 }

                struct Fields {
                    let count = Optic.Field(1, get: { (whole: Counter) in
                            whole.count
                        }, modify: { (whole: inout Counter, transform) in
                            transform(&whole.count)
                        })
                }

                static var fields: Fields {
                    Fields()
                }
            }

            extension Counter: __OpticFieldAccessible {
            }
            """,
        macroSpecs: fieldMacros,
        failureHandler: { failure in
            Issue.record(Comment(rawValue: failure.message))
        }
    )
}

@Test
func `field derivation diagnoses a declaration that is not a struct`() {
    assertMacroExpansion(
        """
        @Fields
        enum Choice {
            case one
        }
        """,
        expandedSource: """
            enum Choice {
                case one
            }
            """,
        diagnostics: [
            DiagnosticSpec(
                message: "@Fields applies to a struct declaration only.",
                line: 1,
                column: 1
            )
        ],
        macroSpecs: fieldMacros,
        failureHandler: { failure in
            Issue.record(Comment(rawValue: failure.message))
        }
    )
}
