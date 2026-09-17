import Optic

@attached(member, names: arbitrary)
public macro Traversals() = #externalMacro(
    module: "Traversal_Macro_Plugin",
    type: "Macro"
)
