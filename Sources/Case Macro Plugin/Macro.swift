#if CaseMacro
    import Case_Macro_Core
    import SwiftSyntax
    import SwiftSyntaxMacros

    public struct Macro: MemberMacro {}

    extension Macro {
        public static func expansion(
            of _: AttributeSyntax,
            providingMembersOf declaration: some DeclGroupSyntax,
            conformingTo _: [TypeSyntax],
            in _: some MacroExpansionContext
        ) throws -> [DeclSyntax] {
            guard let declaration = declaration.as(EnumDeclSyntax.self) else {
                throw MacroExpansionErrorMessage("@Cases applies to an enum declaration only.")
            }
            return Case.Derivation.expansion(of: declaration)
        }
    }
#endif
