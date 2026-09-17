public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public struct Analysis {
        fileprivate let structure: StructDeclSyntax
        fileprivate let fields: [(name: String, type: String)]
        public let diagnostics: [String]

        public init(_ structure: StructDeclSyntax) {
            self.structure = structure
            var fields: [(name: String, type: String)] = []
            var diagnostics: [String] = []

            if structure.memberBlock.members.contains(where: {
                $0.decl.is(InitializerDeclSyntax.self)
            }) {
                diagnostics.append(
                    "@Lenses requires the synthesized memberwise initializer; structs with custom initializers must define their lenses explicitly."
                )
            }

            for member in structure.memberBlock.members {
                guard let variable = member.decl.as(VariableDeclSyntax.self) else { continue }
                if variable.modifiers.contains(where: {
                    ["static", "class"].contains($0.name.text)
                }) {
                    continue
                }

                for binding in variable.bindings {
                    if let accessorBlock = binding.accessorBlock {
                        let hasObserver = accessorBlock.tokens(viewMode: .sourceAccurate).contains {
                            ["willSet", "didSet"].contains($0.text)
                        }
                        if hasObserver {
                            diagnostics.append(
                                "@Lenses does not support observed stored properties; define the lenses explicitly."
                            )
                        }
                        continue
                    }

                    guard
                        let identifier = binding.pattern.as(IdentifierPatternSyntax.self)
                    else {
                        diagnostics.append(
                            "@Lenses requires each stored instance property to use a simple identifier pattern."
                        )
                        continue
                    }
                    let name = identifier.identifier.text
                    guard let type = binding.typeAnnotation?.type.trimmedDescription else {
                        diagnostics.append(
                            "@Lenses requires stored property `\(name)` to have an explicit type annotation."
                        )
                        continue
                    }
                    if variable.modifiers.contains(where: { $0.name.text == "lazy" }) {
                        diagnostics.append(
                            "@Lenses does not support lazy stored property `\(name)` because it is not a memberwise initializer parameter."
                        )
                        continue
                    }
                    if
                        variable.bindingSpecifier.tokenKind == .keyword(.let),
                        binding.initializer != nil
                    {
                        diagnostics.append(
                            "@Lenses does not support initialized constant `\(name)` because it is not a memberwise initializer parameter."
                        )
                        continue
                    }
                    if !variable.attributes.isEmpty {
                        diagnostics.append(
                            "@Lenses does not support attributes or property wrappers on stored property `\(name)`; define the lenses explicitly."
                        )
                        continue
                    }
                    fields.append((name, type))
                }
            }

            self.fields = fields
            self.diagnostics = diagnostics
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
        let parameter = structure.genericParameterClause?.parameters.count == 1
            && structure.genericWhereClause == nil
            && structure.genericParameterClause?.parameters.first?.trimmedDescription
                == structure.genericParameterClause?.parameters.first?.name.text
                ? structure.genericParameterClause?.parameters.first?.name.text
                : nil
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
                selected.type == parameter,
                fields.filter({ $0.name != selected.name }).allSatisfy({ !references(parameter, in: $0.type) })
            {
                let target = "\(whole)<Replacement>"
                let transformedArguments = fields.map { field in
                    "\(field.name): \(field.name == selected.name ? "part" : "whole.\(field.name)")"
                }.joined(separator: ", ")
                declarations += """

                    \(access)func \(selected.name)<Replacement>(
                        to _: Replacement.Type
                    ) -> Optic<
                        \(whole)<\(parameter)>,
                        \(target),
                        \(parameter),
                        Replacement
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
