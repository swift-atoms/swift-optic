import Field_Macro_Core
import SwiftSyntax
import SwiftSyntaxMacros

public struct Macro: MemberMacro, ExtensionMacro {}

extension Macro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("@Fields applies to a struct declaration only.")
        }
        return Field.Derivation.expansion(of: declaration)
    }

    public static func expansion(
        of _: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard declaration.is(StructDeclSyntax.self) else { return [] }
        return Field.Derivation.extensions(of: type)
    }
}
