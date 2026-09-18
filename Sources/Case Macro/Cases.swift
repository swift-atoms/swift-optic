@_exported import Fold_Macro
@_exported import Optic
@_exported import Prism_Macro

// Pairs each case's prism with its fold. Attach beside @Prisms and @Folds, whose namespaces it composes.
@attached(member, names: named(Cases), named(cases))
public macro Cases() = #externalMacro(
    module: "Case_Macro_Plugin",
    type: "Macro"
)
