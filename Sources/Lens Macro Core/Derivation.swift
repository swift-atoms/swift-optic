import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public struct Analysis {
        fileprivate let structure: StructDeclSyntax
        fileprivate let fields: [(name: String, type: String)]
        public let diagnostics: [String]

        public init(_ structure: StructDeclSyntax) {
            self.structure = structure
            let properties = StoredProperties(structure, requiresMemberwise: true)
            self.fields = properties.fields.map { ($0.name, $0.type.trimmedDescription) }
            self.diagnostics = properties.diagnostics.map { "@Lenses " + $0 + "." }
        }
    }

    public static func expansion(of structure: StructDeclSyntax) -> [DeclSyntax] {
        expansion(Analysis(structure))
    }

    public static func expansion(_ analysis: Analysis) -> [DeclSyntax] {
        let structure = analysis.structure
        let whole = structure.name.text
        let access = structure.modifiers
            .first(where: { ["public", "package"].contains($0.name.text) })
            .map { "\($0.name.text) " } ?? ""
        let generic = structure.genericParameterClause?.parameters.first
        let constraint = generic?.inheritedType?.trimmedDescription
        let parameter = structure.genericParameterClause?.parameters.count == 1
            && structure.genericWhereClause == nil && (constraint == nil || constraint == "Sendable")
                ? generic?.name.text : nil
        let replacementConstraint = constraint == "Sendable" ? ": Sendable" : ""
        let fields = analysis.fields

        let properties = fields.map { selected in
            let arguments = fields.map { field in
                "\(field.name): \(field.name == selected.name ? "part" : "whole.\(field.name)")"
            }.joined(separator: ", ")
            var declarations = """
                \(access)var \(selected.name): Optic<\(whole), \(whole), \(selected.type), \(selected.type)>.Lens {
                    .init(decompose: { whole in
                        (
                            focus: whole.\(selected.name),
                            reconstruct: { part in \(whole)(\(arguments)) }
                        )
                    })
                }
                """

            if
                let parameter,
                (selected.type == parameter || selected.type == "[\(parameter)]"),
                fields.filter({ $0.name != selected.name }).allSatisfy({ !references(parameter, in: $0.type) })
            {
                let target = "\(whole)<Replacement>"
                let replacement = selected.type == parameter ? "Replacement" : "[Replacement]"
                let transformedArguments = fields.map { field in
                    "\(field.name): \(field.name == selected.name ? "part" : "whole.\(field.name)")"
                }.joined(separator: ", ")
                declarations += """

                    \(access)func \(selected.name)<Replacement\(replacementConstraint)>(
                        to _: Replacement.Type
                    ) -> Optic<
                        \(whole)<\(parameter)>,
                        \(target),
                        \(selected.type),
                        \(replacement)
                    >.Lens {
                        .init(decompose: { whole in
                            (
                                focus: whole.\(selected.name),
                                reconstruct: { part in \(target)(\(transformedArguments)) }
                            )
                        })
                    }
                    """
            }
            return declarations
        }.joined(separator: "\n")

        return ["""
            \(raw: access)struct Lenses {
                \(raw: properties)
            }

            \(raw: access)static var lenses: Lenses {
                Lenses()
            }
            """]
    }

    private static func references(_ name: String, in type: String) -> Bool {
        type.split(whereSeparator: isTypeSeparator).contains { String($0) == name }
    }

    private static func isTypeSeparator(_ character: Character) -> Bool {
        " <>[](),?!&.:".contains(character)
    }
}
