import Optic

@attached(member, names: arbitrary)
public macro Affine() = #externalMacro(
    module: "Traversal_Affine_Macro_Plugin",
    type: "Macro"
)
