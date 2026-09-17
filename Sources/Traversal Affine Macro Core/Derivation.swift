public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of enumDeclaration: EnumDeclSyntax) -> [DeclSyntax] {
        let whole = enumDeclaration.name.text
        let cases = enumDeclaration.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap(\.elements)
        let parameter = enumDeclaration.genericParameterClause?.parameters.count == 1
            && enumDeclaration.genericWhereClause == nil
            && enumDeclaration.genericParameterClause?.parameters.first?.trimmedDescription
                == enumDeclaration.genericParameterClause?.parameters.first?.name.text
                ? enumDeclaration.genericParameterClause?.parameters.first?.name.text
                : nil

        let properties = cases.compactMap { element -> String? in
            guard
                let parameters = element.parameterClause?.parameters,
                parameters.count == 1,
                let type = parameters.first?.type.trimmedDescription
            else { return nil }
            let name = element.name.text
            var declaration = """
                var \(name): Optic<\(whole), \(whole), \(type), \(type)>.Affine {
                    .init(decompose: { whole in
                        guard case let .\(name)(value) = whole else { return .left(whole) }
                        return .right(
                            (
                                focus: value,
                                reconstruct: { .\(name)($0) }
                            )
                        )
                    })
                }
                """
            if
                let parameter,
                type == parameter,
                cases.filter({ $0.name.text != name }).allSatisfy({ other in
                    other.parameterClause?.parameters.allSatisfy {
                        !references(parameter, in: $0.type.trimmedDescription)
                    } ?? true
                })
            {
                let unmatched = cases.filter { $0.name.text != name }.map { other in
                    let otherName = other.name.text
                    let count = other.parameterClause?.parameters.count ?? 0
                    guard count > 0 else {
                        return "case .\(otherName): return .left(.\(otherName))"
                    }
                    let values = (0..<count).map { "value\($0)" }
                    return "case let .\(otherName)(\(values.joined(separator: ", "))): return .left(.\(otherName)(\(values.joined(separator: ", "))))"
                }.joined(separator: "\n")
                declaration += """

                    func \(name)<Replacement>(
                        to _: Replacement.Type
                    ) -> Optic<
                        \(whole)<\(parameter)>,
                        \(whole)<Replacement>,
                        \(parameter),
                        Replacement
                    >.Affine {
                        .init(decompose: {
                            switch $0 {
                            case let .\(name)(value):
                                return .right(
                                    (
                                        focus: value,
                                        reconstruct: { .\(name)($0) }
                                    )
                                )
                            \(unmatched)
                            }
                        })
                    }
                    """
            }
            return declaration
        }.joined(separator: "\n")

        return ["""
            struct Affine {
                \(raw: properties)
            }

            static var affine: Affine {
                Affine()
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
