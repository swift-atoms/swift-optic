public import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public typealias Analysis = Type.Syntax.Properties

    public static func expansion(of structure: StructDeclSyntax) -> [DeclSyntax] {
        expansion(Analysis(structure, requiresMemberwise: true))
    }

    public static func expansion(_ analysis: Analysis) -> [DeclSyntax] {
        do { return try derive(analysis) }
        catch { return [DeclSyntax(stringLiteral: "#error(\(String(reflecting: String(describing: error))))")] }
    }

    private static func derive(_ analysis: Analysis) throws -> [DeclSyntax] {
        let structure = analysis.declaration
        let whole = structure.name.text
        let fields = analysis.fields.map { (name: $0.name, type: $0.type.trimmedDescription) }

        let record = try Type.Syntax.Record(fields.map { .init($0.name, type: $0.type) })
        let part = record.tupleType
        let forward = record.projecting("$0").expression
        let backward = try record.constructing(whole, from: record.unpacking("$0"))

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
                    backward: { \(backward) }
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
            let replacementRecord = try Type.Syntax.Record(fields.map {
                .init($0.name, type: $0.type == parameter ? replacement : $0.type)
            })
            let replacementPart = replacementRecord.tupleType
            let reconstruction = try replacementRecord.constructing(target, from: replacementRecord.unpacking("$0"))

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
                        backward: { \(reconstruction) }
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
        !Type.Syntax.Expression.references(in: TypeSyntax(stringLiteral: type), parameters: [name]).isEmpty
    }
}
