@_exported import Either
@_exported import Optic

@attached(member, names: named(Prisms), named(prisms))
@attached(extension, conformances: __OpticPrismAccessible)
public macro Prisms() = #externalMacro(
    module: "Prism_Macro_Plugin",
    type: "Macro"
)
