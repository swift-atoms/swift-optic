#if LensMacro || TraversalMacro
    @_exported import Optic

    @attached(member, names: named(Lenses), named(lenses))
    public macro Lenses() =
        #externalMacro(
            module: "Lens_Macro_Plugin",
            type: "Macro"
        )
#endif
