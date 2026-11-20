import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    #if Coproduct
        let providingMacros: [any SwiftSyntaxMacros.Macro.Type] = [Macro.self]
    #else
        let providingMacros: [any SwiftSyntaxMacros.Macro.Type] = []
    #endif
}
