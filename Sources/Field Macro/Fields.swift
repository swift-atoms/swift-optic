@_exported import Optic

@attached(member, names: named(Fields), named(fields))
@attached(extension, conformances: __OpticFieldAccessible)
public macro Fields() =
    #externalMacro(
        module: "Field_Macro_Plugin",
        type: "Macro"
    )
