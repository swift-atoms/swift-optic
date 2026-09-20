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
        let access = structure.modifiers
            .first(where: { ["public", "package"].contains($0.name.text) })
            .map { "\($0.name.text) " } ?? ""
        let generic = structure.genericParameterClause?.parameters.first
        let constraint = generic?.inheritedType?.trimmedDescription
        let parameter = structure.genericParameterClause?.parameters.count == 1
            && structure.genericWhereClause == nil && (constraint == nil || constraint == "Sendable")
                ? generic?.name.text : nil
        let replacementConstraint = constraint == "Sendable" ? ": Sendable" : ""
        let fields = analysis.fields.map { (name: $0.name, type: $0.type.trimmedDescription) }

        let record = try Type.Syntax.Record(fields.map { .init($0.name, type: $0.type) })
        let wholeValue = record.projecting("whole")
        let input = Type.Syntax.Interpretation.Product.product([wholeValue, .value("part")])
        let properties = try fields.map { selected in
            let lens = try Type.Lens.coordinate(selected.name, in: record.algebra)
            let focus = try wholeValue.applying(lens.get).expression
            let reconstruction = try record.constructing(whole, from: input.applying(lens.put))
            var declarations = """
                \(access)var \(selected.name): Optic<\(whole), \(whole), \(selected.type), \(selected.type)>.Lens {
                    .init(decompose: { whole in
                        (
                            focus: \(focus),
                            reconstruct: { part in \(reconstruction) }
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
                let changed = try Type.Lens.coordinate(selected.name, in: record.algebra,
                    replacingWith: .atom(.init(replacement, scope: ["Swift"])))
                let transformed = try record.constructing(target, from: input.applying(changed.put))
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
                                focus: \(focus),
                                reconstruct: { part in \(transformed) }
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
        !Type.Syntax.Expression.references(in: TypeSyntax(stringLiteral: type), parameters: [name]).isEmpty
    }
}
