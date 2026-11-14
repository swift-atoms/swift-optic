@attached(member, names: named(Fields), named(fields), named(__fieldIdentity))
@attached(extension, conformances: __OpticFieldAccessible)
public macro Fields() =
    #externalMacro(
        module: "Field_Macro_Plugin",
        type: "Macro"
    )
