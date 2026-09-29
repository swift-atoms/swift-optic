public import SwiftSyntax
public import Coproduct_Syntax
import SwiftSyntaxBuilder

extension Prism {
    public enum Derivation {
        public static func extensions(
            of type: some TypeSyntaxProtocol
        ) -> [ExtensionDeclSyntax] {

            let declaration: DeclSyntax = """
                extension \(type.trimmed): __OpticPrismAccessible {}
                """
            return declaration.as(ExtensionDeclSyntax.self).map { [$0] } ?? []
        }

        public static func expansion(
            of declaration: EnumDeclSyntax
        ) -> [DeclSyntax] {
            expansion(Coproduct.Analysis(declaration))
        }

        public static func expansion(_ analysis: Coproduct.Analysis) -> [DeclSyntax] {
            let access = analysis.access.map { "\($0.name.text) " } ?? ""
            let members = analysis.cases.map {
                property($0, analysis: analysis, access: access)
            }.joined(separator: "\n")

            return ["""
                \(raw: access)struct Prisms {
                    \(raw: members)
                }
                """, """
                \(raw: access)static var prisms: Prisms {
                    Prisms()
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
            let payload = coproductCase.payload.trimmedDescription

            let embed: String
            switch coproductCase.parameters.count {
            case 0: embed = "{ _ in .\(name) }"
            case 1: embed = "{ .\(name)(\(coproductCase.constructorArguments(["$0"]))) }"
            default:
                let binding = analysis.isCopyableSuppressed ? "payload" : "$0"
                let projected = coproductCase.parameters.indices.map { "\(binding).\($0)" }
                let constructor = ".\(name)(\(coproductCase.constructorArguments(projected)))"
                embed = analysis.isCopyableSuppressed
                    ? "{ (payload: consuming \(payload)) in \(constructor) }"
                    : "{ \(constructor) }"
            }
            var declaration = """
                \(access)var \(name): Optic<\(whole), \(whole), \(payload), \(payload)>.Prism {
                    .init(
                        match: { whole in
                            \(matchBody(for: coproductCase, in: analysis, consuming: "whole"))
                        },
                        embed: \(embed)
                    )
                }
                """
            if
                let parameter = analysis.genericParameter,
                coproductCase.isDirectReference(to: parameter),
                analysis.cases
                    .filter({ $0.name.text != name })
                    .allSatisfy({ !$0.references(parameter) })
            {
                declaration += """

                    \(access)func \(name)<Replacement>(
                        to _: Replacement.Type
                    ) -> Optic<
                        \(whole)<\(parameter.text)>,
                        \(whole)<Replacement>,
                        \(parameter.text),
                        Replacement
                    >.Prism {
                        .init(
                            match: { whole in
                                \(matchBody(for: coproductCase, in: analysis, consuming: "whole"))
                            },
                            embed: { .\(name)(\(coproductCase.constructorArguments(["$0"]))) }
                        )
                    }
                    """
            }
            return declaration
        }

        private static func matchBody(
            for selected: Coproduct.Analysis.Case,
            in analysis: Coproduct.Analysis,
            consuming value: String
        ) -> String {
            let branches = analysis.cases.map { coproductCase in
                coproductCase.name.text == selected.name.text
                    ? matchingBranch(coproductCase)
                    : unmatchedBranch(coproductCase)
            }.joined(separator: "\n")
            let switchValue = analysis.isCopyableSuppressed
                ? "consume \(value)"
                : value
            return """
                switch \(switchValue) {
                \(branches)
                }
                """
        }

        private static func matchingBranch(
            _ coproductCase: Coproduct.Analysis.Case
        ) -> String {
            let values = coproductCase.bindings()
            return "case \(coproductCase.pattern()): return .right(\(coproductCase.payloadExpression(values)))"
        }

        private static func unmatchedBranch(
            _ coproductCase: Coproduct.Analysis.Case
        ) -> String {
            let name = coproductCase.name.text
            guard !coproductCase.parameters.isEmpty else {
                return "case .\(name): return .left(.\(name))"
            }
            let values = coproductCase.bindings()
            return "case \(coproductCase.pattern()): return .left(.\(name)(\(coproductCase.constructorArguments(values))))"
        }
    }
}
