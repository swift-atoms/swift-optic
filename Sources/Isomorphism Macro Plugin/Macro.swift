#if IsomorphismMacro
    import Isomorphism_Macro_Core
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
            guard let declaration = declaration.as(StructDeclSyntax.self) else {
                throw MacroExpansionErrorMessage("@Isomorphism applies to a struct declaration only.")
            }
            let analysis = Derivation.Analysis(declaration, requiresMemberwise: true)
            if let diagnostic = analysis.diagnostics.first {
                throw MacroExpansionErrorMessage("@Isomorphism " + diagnostic + ".")
            }
            return Derivation.expansion(analysis)
        }
    }
#endif
