#if CaseMacro || FoldMacro
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct Plugin: CompilerPlugin {
        let providingMacros: [any SwiftSyntaxMacros.Macro.Type] = [Macro.self]
    }
#endif
