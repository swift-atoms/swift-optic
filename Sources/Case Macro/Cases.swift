@_exported import Fold_Macro
@_exported import Optic
@_exported import Prism_Macro

@attached(member, names: named(Cases), named(cases))
public macro Cases() = #externalMacro(
    module: "Case_Macro_Plugin",
    type: "Macro"
)
