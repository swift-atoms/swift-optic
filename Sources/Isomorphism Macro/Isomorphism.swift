@_exported import Optic

@attached(member, names: arbitrary)
public macro Isomorphism() = #externalMacro(
    module: "Isomorphism_Macro_Plugin",
    type: "Macro"
)
