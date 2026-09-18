@_exported import Either
@_exported import Optic

// `__OpticPrismAccessible` is the accessor conformance: it is what lets `value.someCase` and `prism.someCase`
// reach the derived `Prisms` by dynamic member lookup. It is part of the derivation's public surface by necessity
// (the conformance sits on the attached type), not a marker of anything else.
@attached(member, names: named(Prisms), named(prisms))
@attached(extension, conformances: __OpticPrismAccessible)
public macro Prisms() = #externalMacro(
    module: "Prism_Macro_Plugin",
    type: "Macro"
)
