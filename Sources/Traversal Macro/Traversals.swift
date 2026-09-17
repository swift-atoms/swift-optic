import Optic

@attached(member, names: named(Traversals), named(traversals))
public macro Traversals() = #externalMacro(
    module: "Traversal_Macro_Plugin",
    type: "Macro"
)
