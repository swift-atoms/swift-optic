import Field_Macro_Core
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct Macro: MemberMacro, ExtensionMacro {}

extension Macro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: node,
                    message: MacroExpansionErrorMessage("@Fields applies to a struct declaration only.")
                )
            )
            return []
        }
        return Field.Derivation.expansion(of: declaration)
    }

    public static func expansion(
        of _: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) -> [ExtensionDeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else { return [] }
        return Field.Derivation.extensions(of: type, declaredBy: declaration)
    }
}
