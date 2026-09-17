@_exported import Optic

@attached(member, names: arbitrary)
public macro Lenses() = #externalMacro(
    module: "Lens_Macro_Plugin",
    type: "Macro"
)
