public import SwiftSyntax
import SwiftSyntaxBuilder

extension Field {
    public enum Derivation {}
}

extension Field.Derivation {
    public static func extensions(
        of type: some TypeSyntaxProtocol
    ) -> [ExtensionDeclSyntax] {
        let declaration: DeclSyntax = """
            extension \(type.trimmed): __OpticFieldAccessible {}
            """
        return declaration.as(ExtensionDeclSyntax.self).map { [$0] } ?? []
    }

    /// One field per stored instance `var`, in declaration order. A `let`, a computed property and
    /// a static property are not stored parts that can be changed in place, so they get no field,
    /// but a `let` still counts for the positions of the properties after it. So does a property
    /// with an attribute: a property wrapper or an attached macro may make it read-only, which
    /// this derivation cannot see, so it gets no field and keeps its position.
    public static func expansion(of structure: StructDeclSyntax) -> [DeclSyntax] {
        let whole = structure.name.text
        let access =
            structure.modifiers
            .first(where: { ["public", "package"].contains($0.name.text) })
            .map { "\($0.name.text) " } ?? ""
        var position = 0
        var members: [Swift::String] = []
        for member in structure.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self), stored(variable) else { continue }
            for binding in variable.bindings {
                guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { continue }
                defer { position += 1 }
                guard variable.bindingSpecifier.tokenKind == .keyword(.var), variable.attributes.isEmpty
                else { continue }
                members.append(
                    "\(access)let \(name) = Optic.Field(identity: .init(positions: [\(position)]), "
                        + "get: { (whole: \(whole)) in whole.\(name) }, "
                        + "modify: { (whole: inout \(whole), transform) in transform(&whole.\(name)) })"
                )
            }
        }
        let initializer = access.isEmpty ? "" : "\n\(access)init() {}"
        return [
            """
            \(raw: access)struct Fields {
                \(raw: members.joined(separator: "\n"))\(raw: initializer)
            }
            """,
            """
            \(raw: access)static var fields: Fields {
                Fields()
            }
            """,
        ]
    }

    private static func stored(_ variable: VariableDeclSyntax) -> Swift::Bool {
        guard !variable.modifiers.contains(where: { ["static", "class", "lazy"].contains($0.name.text) })
        else { return false }
        return variable.bindings.allSatisfy { binding in
            guard let accessors = binding.accessorBlock else { return true }
            guard case .accessors(let list) = accessors.accessors else { return false }
            return list.allSatisfy { ["willSet", "didSet"].contains($0.accessorSpecifier.text) }
        }
    }
}
