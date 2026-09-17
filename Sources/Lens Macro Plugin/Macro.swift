import SwiftSyntax
import SwiftSyntaxMacros
import Lens_Macro_Core

public struct Macro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("@Lenses applies to a struct declaration only.")
        }
        let analysis = Derivation.Analysis(declaration)
        if let diagnostic = analysis.diagnostics.first {
            throw MacroExpansionErrorMessage(diagnostic)
        }
        return Derivation.expansion(analysis)
    }
}
