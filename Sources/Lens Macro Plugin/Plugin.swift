#if LensMacro || TraversalMacro
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct Plugin: CompilerPlugin {
        let providingMacros: [any SwiftSyntaxMacros.Macro.Type] = [Macro.self]
    }
#else
    @main
    struct Plugin {
        static func main() {}
    }
#endif
