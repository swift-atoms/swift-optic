public import SwiftSyntax
public import Coproduct_Macro_Core
import SwiftSyntaxBuilder

extension Fold {
    public enum Derivation {
        public static func expansion(
            of declaration: EnumDeclSyntax
        ) -> [DeclSyntax] {
            expansion(Coproduct.Analysis(declaration))
        }

        public static func expansion(
            whole: TypeSyntax,
            access: DeclModifierSyntax?,
            cases: [EnumCaseElementSyntax],
            genericParameter: TokenSyntax?
        ) -> [DeclSyntax] {
            expansion(
                Coproduct.Analysis(
                    whole: whole,
                    access: access,
                    cases: cases,
                    genericParameter: genericParameter
                )
            )
        }

        public static func expansion(_ analysis: Coproduct.Analysis) -> [DeclSyntax] {
            let access = analysis.access.map { "\($0.name.text) " } ?? ""
            let members = analysis.cases.map {
                property($0, analysis: analysis, access: access)
            }.joined(separator: "\n")

            return ["""
                \(raw: access)struct Folds {
                    \(raw: members)
                }

                \(raw: access)static var folds: Folds {
                    Folds()
                }
                """]
        }

        private static func property(
            _ coproductCase: Coproduct.Analysis.Case,
            analysis: Coproduct.Analysis,
            access: String
        ) -> String {
            let name = coproductCase.name.text
            let whole = analysis.whole.trimmedDescription
            let payload = coproductCase.parameters.isEmpty
                ? "Void"
                : coproductCase.payload.trimmedDescription
            let branches = analysis.cases.map { candidate in
                candidate.name.text == name
                    ? visitingBranch(candidate)
                    : "case .\(candidate.name.text): return false"
            }.joined(separator: "\n")
            return """
                \(access)var \(name): Optic<\(whole), \(whole), \(payload), \(payload)>.Fold {
                    .init { whole, visit in
                        switch whole {
                        \(branches)
                        }
                    }
                }
                """
        }

        private static func visitingBranch(_ coproductCase: Coproduct.Analysis.Case) -> String {
            let values = coproductCase.bindings()
            return "case \(coproductCase.pattern()): visit(\(coproductCase.payloadExpression(values))); return true"
        }
    }
}
