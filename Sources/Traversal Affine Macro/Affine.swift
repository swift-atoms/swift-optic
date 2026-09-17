import Optic

@attached(member, names: named(Affine), named(affine))
public macro Affine() = #externalMacro(
    module: "Traversal_Affine_Macro_Plugin",
    type: "Macro"
)
