public import SwiftSyntax
public import Coproduct_Macro_Core
import SwiftSyntaxBuilder

extension Case {
    // A case is its prism paired with its fold. The derivation composes the `Prisms` and `Folds` namespaces the
    // @Prisms and @Folds macros declare on the same enum; it does not re-derive either optic.
    public enum Derivation {
        public static func expansion(
            of declaration: EnumDeclSyntax
        ) -> [DeclSyntax] {
            expansion(Coproduct.Analysis(declaration))
        }

        public static func expansion(_ analysis: Coproduct.Analysis) -> [DeclSyntax] {
            let access = analysis.access.map { "\($0.name.text) " } ?? ""
            let whole = analysis.whole.trimmedDescription
            let members = analysis.cases.map { coproductCase in
                let name = coproductCase.name.text
                let payload = coproductCase.parameters.isEmpty ? "Void" : coproductCase.payload.trimmedDescription
                return """
                    \(access)var \(name): Optic<\(whole), \(whole), \(payload), \(payload)>.Case {
                        .init(prism: \(whole).prisms.\(name), fold: \(whole).folds.\(name))
                    }
                    """
            }.joined(separator: "\n")

            return ["""
                \(raw: access)struct Cases {
                    \(raw: members)
                }

                \(raw: access)static var cases: Cases {
                    Cases()
                }
                """]
        }
    }
}
