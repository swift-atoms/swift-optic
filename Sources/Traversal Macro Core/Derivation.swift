public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of structure: StructDeclSyntax) -> [DeclSyntax] {
        let whole = structure.name.text

        let genericParameter = structure.genericParameterClause?.parameters.first
        let parameter = structure.genericParameterClause?.parameters.count == 1
            && structure.genericWhereClause == nil
            && genericParameter?.inheritedType?.trimmedDescription == "Sendable"
                ? genericParameter?.name.text
                : nil
        let fields = structure.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .flatMap(\.bindings)
            .compactMap { binding -> (name: String, type: String, element: String?)? in
                guard
                    let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                    let type = binding.typeAnnotation?.type
                else { return nil }
                return (
                    name,
                    type.trimmedDescription,
                    type.as(ArrayTypeSyntax.self)?.element.trimmedDescription
                )
            }
        let arrays = fields.compactMap { field -> (name: String, element: String)? in
            guard let element = field.element else { return nil }
            return (field.name, element)
        }

        let properties = arrays.map { field in
            var declaration = """
            var \(field.name): Optic<\(whole), \(whole), \(field.element), \(field.element)>.Traversal {
                .init(decompose: { whole in
                    .init(
                        focuses: whole.\(field.name),
                        reconstruct: { replacements in
                            var target = whole
                            target.\(field.name) = replacements
                            return target
                        }
                    )
                })
            }
            """
            if
                let parameter,
                field.element == parameter,
                fields.filter({ $0.name != field.name }).allSatisfy({ !references(parameter, in: $0.type) })
            {
                let arguments = fields.map { candidate in
                    "\(candidate.name): \(candidate.name == field.name ? "replacements" : "whole.\(candidate.name)")"
                }.joined(separator: ", ")
                declaration += """

                    func \(field.name)<Replacement: Sendable>(
                        to _: Replacement.Type
                    ) -> Optic<
                        \(whole)<\(parameter)>,
                        \(whole)<Replacement>,
                        \(parameter),
                        Replacement
                    >.Traversal {
                        .init(decompose: { whole in
                            .init(
                                focuses: whole.\(field.name),
                                reconstruct: { replacements in
                                    \(whole)<Replacement>(\(arguments))
                                }
                            )
                        })
                    }
                    """
            }
            return declaration
        }.joined(separator: "\n")

        return ["""
            struct Traversals {
                \(raw: properties)
            }

            static var traversals: Traversals {
                Traversals()
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
