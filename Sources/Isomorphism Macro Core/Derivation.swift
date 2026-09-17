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
                    "@Isomorphism requires the synthesized memberwise initializer; structs with custom initializers must define their isomorphism explicitly."
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
                                "@Isomorphism does not support observed stored properties; define the isomorphism explicitly."
                            )
                        }
                        continue
                    }

                    guard
                        let identifier = binding.pattern.as(IdentifierPatternSyntax.self)
                    else {
                        diagnostics.append(
                            "@Isomorphism requires each stored instance property to use a simple identifier pattern."
                        )
                        continue
                    }
                    let name = identifier.identifier.text
                    guard let type = binding.typeAnnotation?.type.trimmedDescription else {
                        diagnostics.append(
                            "@Isomorphism requires stored property `\(name)` to have an explicit type annotation."
                        )
                        continue
                    }
                    if variable.modifiers.contains(where: { $0.name.text == "lazy" }) {
                        diagnostics.append(
                            "@Isomorphism does not support lazy stored property `\(name)` because it is not a memberwise initializer parameter."
                        )
                        continue
                    }
                    if
                        variable.bindingSpecifier.tokenKind == .keyword(.let),
                        binding.initializer != nil
                    {
                        diagnostics.append(
                            "@Isomorphism does not support initialized constant `\(name)` because it is not a memberwise initializer parameter."
                        )
                        continue
                    }
                    if !variable.attributes.isEmpty {
                        diagnostics.append(
                            "@Isomorphism does not support attributes or property wrappers on stored property `\(name)`; define the isomorphism explicitly."
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
        let fields = analysis.fields

        let part: String
        let forward: String
        switch fields.count {
        case 0:
            part = "Void"
            forward = "()"
        case 1:
            part = fields[0].type
            forward = "$0.\(fields[0].name)"
        default:
            part = "(\(fields.map(\.type).joined(separator: ", ")))"
            forward = "(\(fields.map { "$0.\($0.name)" }.joined(separator: ", ")))"
        }

        let arguments = fields.enumerated().map { index, field in
            "\(field.name): \(fields.count == 1 ? "$0" : "$0.\(index)")"
        }.joined(separator: ", ")

        let access = structure.modifiers
            .first(where: { ["public", "package"].contains($0.name.text) })
            .map { "\($0.name.text) " } ?? ""
        var members: [String] = ["""
            /// The exact stored-property/memberwise representation.
            ///
            /// This is derived only when construction uses Swift's synthesized
            /// memberwise initializer. Construction and projection therefore
            /// use the same stored instance properties in declaration order.
            \(access)var memberwise: Optic<\(whole), \(whole), \(part), \(part)>.Isomorphism {
                .init(
                    forward: { \(forward) },
                    backward: { \(whole)(\(arguments)) }
                )
            }
            """]

        if
            let parameter = structure.genericParameterClause?.parameters.first?.name.text,
            structure.genericParameterClause?.parameters.count == 1,
            structure.genericParameterClause?.parameters.first?.trimmedDescription == parameter,
            structure.genericWhereClause == nil,
            fields.allSatisfy({ field in
                field.type == parameter || !references(parameter, in: field.type)
            }),
            fields.contains(where: { $0.type == parameter })
        {
            let replacement = "Replacement"
            let target = "\(whole)<\(replacement)>"
            let source = "\(whole)<\(parameter)>"
            let replacementPart: String
            switch fields.count {
            case 0:
                replacementPart = "Void"
            case 1:
                replacementPart = fields[0].type == parameter ? replacement : fields[0].type
            default:
                replacementPart = "(\(fields.map { $0.type == parameter ? replacement : $0.type }.joined(separator: ", ")))"
            }
            let replacementArguments = fields.enumerated().map { index, field in
                "\(field.name): \(fields.count == 1 ? "$0" : "$0.\(index)")"
            }.joined(separator: ", ")

            members.append("""
                /// The type-changing stored-property/memberwise representation.
                ///
                /// This belongs to the family formed by replacing the sole bare
                /// generic parameter in the synthesized memberwise initializer.
                \(access)func memberwise<\(replacement)>(
                    to _: \(replacement).Type
                ) -> Optic<
                    \(source),
                    \(target),
                    \(part),
                    \(replacementPart)
                >.Isomorphism {
                    .init(
                        forward: { \(forward) },
                        backward: { \(target)(\(replacementArguments)) }
                    )
                }
                """)
        }

        let properties = members.joined(separator: "\n\n")
        return ["""
            \(raw: access)struct Isomorphisms {
                \(raw: properties)
            }

            \(raw: access)static var isomorphisms: Isomorphisms {
                Isomorphisms()
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
