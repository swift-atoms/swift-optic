@_exported import Optic

@attached(member, names: arbitrary)
public macro Folds() = #externalMacro(
    module: "Fold_Macro_Plugin",
    type: "Macro"
)
