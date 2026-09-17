import SwiftSyntax
import SwiftSyntaxMacros
import Traversal_Macro_Core

public struct Macro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("@Traversals applies to a struct declaration only.")
        }
        return Derivation.expansion(of: declaration)
    }
}
