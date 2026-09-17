@_exported import Optic

@attached(member, names: named(Isomorphisms), named(isomorphisms))
public macro Isomorphism() = #externalMacro(
    module: "Isomorphism_Macro_Plugin",
    type: "Macro"
)
