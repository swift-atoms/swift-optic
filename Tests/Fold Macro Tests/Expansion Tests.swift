import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import Fold_Macro_Plugin

private let foldMacros: [String: MacroSpec] = [
    "Folds": MacroSpec(type: Fold_Macro_Plugin.Macro.self)
]

@Test
func `fold derivation diagnoses a non enum attachment`() {
    assertMacroExpansion(
        """
        @Folds
        struct Choice {}
        """,
        expandedSource: """
        struct Choice {}
        """,
        diagnostics: [
            DiagnosticSpec(
                message: "@Folds applies to an enum declaration only.",
                line: 1,
                column: 1
            )
        ],
        macroSpecs: foldMacros,
        failureHandler: { failure in
            Issue.record(Comment(rawValue: failure.message))
        }
    )
}
