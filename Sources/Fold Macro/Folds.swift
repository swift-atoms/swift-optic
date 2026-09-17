@_exported import Optic

@attached(member, names: named(Folds), named(folds))
public macro Folds() = #externalMacro(
    module: "Fold_Macro_Plugin",
    type: "Macro"
)
