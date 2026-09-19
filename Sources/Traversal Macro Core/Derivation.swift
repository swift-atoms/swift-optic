public import SwiftSyntax
import SwiftSyntaxBuilder
import Type_Algebra_Syntax

public enum Derivation {
    public static func expansion(of structure: StructDeclSyntax) -> [DeclSyntax] {
        let analysis = StoredProperties(structure, requiresMemberwise: true)
        guard analysis.diagnostics.isEmpty else {
            return [DeclSyntax(stringLiteral: "#error(\"@Traversals " + analysis.diagnostics.joined(separator: "; ") + "\")")]
        }
        guard structure.attributes.contains(where: { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "Lenses" }) else {
            return ["#error(\"@Traversals requires @Lenses on the same source declaration; it cannot attach a macro to its own type.\")"]
        }
        let whole = structure.name.text
        let access = structure.modifiers.first { ["public", "package"].contains($0.name.text) }.map { "\($0.name.text) " } ?? ""
        let generic = structure.genericParameterClause?.parameters.first
        let parameter = structure.genericParameterClause?.parameters.count == 1 && structure.genericWhereClause == nil
            && (generic?.inheritedType == nil || generic?.inheritedType?.trimmedDescription == "Sendable") ? generic?.name.text : nil
        let constraint = generic?.inheritedType?.trimmedDescription == "Sendable" ? ": Sendable" : ""
        let members = analysis.fields.compactMap { field -> String? in
            guard let element = field.type.as(ArrayTypeSyntax.self)?.element.trimmedDescription else { return nil }
            var member = """
                \(access)var \(field.name): Optic<\(whole), \(whole), \(element), \(element)>.Traversal {
                    Optic<\(whole), \(whole), [\(element)], [\(element)]>.Traversal(\(whole).lenses.\(field.name)).appending(.each)
                }
                """
            if let parameter, element == parameter,
                analysis.fields.filter({ $0.name != field.name }).allSatisfy({ !$0.type.tokens(viewMode: .sourceAccurate).contains { $0.text == parameter } }) {
                member += """

                    \(access)func \(field.name)<Replacement\(constraint)>(to _: Replacement.Type) -> Optic<\(whole)<\(parameter)>, \(whole)<Replacement>, \(parameter), Replacement>.Traversal {
                        Optic<\(whole)<\(parameter)>, \(whole)<Replacement>, [\(parameter)], [Replacement]>.Traversal(\(whole).lenses.\(field.name)(to: Replacement.self)).appending(.each)
                    }
                    """
            }
            return member
        }
        return [DeclSyntax(stringLiteral: """
            \(access)struct Traversals {
                \(members.joined(separator: "\n"))
            }
            \(access)static var traversals: Traversals { .init() }
            """)]
    }
}
