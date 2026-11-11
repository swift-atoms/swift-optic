# swift-optic

Use this package to read, replace, match or transform part of a value without writing the code that rebuilds the whole by hand. Choose the optic kind by how many focuses the part has and whether reaching it can fail: `Optic.Isomorphism` for a lossless change of representation, `Optic.Lens` for exactly one focus, `Optic.Prism` for one enum case that may be absent and can build the whole from the part, `Optic.Affine` for zero or one focus, `Optic.Traversal` for zero or more focuses in order, `Optic.Setter` to update only, `Optic.Fold` to read through a borrow, and `Optic.Isomorphism.Partial` or `Optic.Adapter` when the conversions throw. Every kind is nested in `Optic<Source, Target, Focus, Replacement>`: putting a `Replacement` where the `Focus` was turns a `Source` into a `Target`, so type-changing updates use the same types as in-place ones. To derive optics, put `@Lenses`, `@Isomorphism` and `@Traversals` on structs, and `@Prisms`, `@Folds` and `@Cases` on enums. To compose two optics, use `>>>`, which returns the weaker of the two kinds, so a lens followed by a prism gives an affine.

## Laws

- The initializers accept any closures and do not check the optic laws. Callers must keep them; the tests check them:
  - `Optic.Isomorphism`: going forward then backward returns the original value, and so does going backward then forward.
  - `Optic.Lens`: reading after a set returns the new part, setting the current part changes nothing, and of two sets the last one wins.
  - `Optic.Prism`: matching an embedded part gives that part back, and embedding a matched part gives back the source.
  - `Optic.Field`: the lens laws, stated for a change made in place: reading after a change gives the changed part, a change that does nothing leaves the whole as it was, and of two changes the last one wins.
  - `Optic.Setter` and `Optic.Traversal`: mapping with the identity changes nothing, and two maps in a row equal one map with the composed function.
  - `Optic.Isomorphism.Partial` keeps the inverse laws only where both directions succeed, and composing two of them narrows that domain.
- A miss is not an error, and the transform is never called on one. `match` returns the source, rebuilt as `Target`, on the left. `map` and `modify` on an `Optic.Prism`, and `map`, `modify` and `set` on an `Optic.Affine` or an `Optic.Setter` built from either, return the source unchanged. When the inner optic of a composed prism or affine misses, the outer one rebuilds the whole, so the left side always holds a complete `Target`.
- `Optic.Traversal` visits focuses in source order. Composing traversals flattens the outer focuses before the inner ones, and replacements are matched to focuses by position. The `modify` closure given to `Optic.Traversal.init(get:modify:)` must call its transform once for each element that `get` returned, in the same order.
- A composed `Optic.Adapter` or `Optic.Isomorphism.Partial` stops at the first failure. In both directions `.left` means the left-hand optic failed and `.right` means the right-hand one failed, even though going backward runs the right-hand optic first.
- `Optic.Fold.visit` returns whether a focus was visited, and `Optic.Fold.extract` keeps the last focus visited. If you build an `Optic.Case` from a separate prism and fold, the fold must visit exactly when the prism matches. `init(_:)` avoids this by deriving the fold from the prism.
- `@Lenses`, `@Isomorphism` and `@Traversals` reject a struct that does not use the synthesized memberwise initializer, a stored property without an explicit type, or a `let` with an initial value. They cover stored instance properties only, in declaration order.
  - `memberwise` on a struct with one stored property focuses that property's type, not a one-element tuple.
  - `@Traversals` requires `@Lenses` on the same struct. It derives members only for properties of array type, each focusing every element of its array.
  - `@Cases` requires `@Prisms` and `@Folds` on the same enum.
  - A case without a payload has the focus `Void`. A payload of several values becomes a tuple that keeps the case's labels.
- A type-changing `to:` overload is generated only under all of these conditions:
  - the type has a single generic parameter and no `where` clause;
  - the member's type is that parameter (`@Lenses` also accepts an array of it, and `@Traversals` requires an array of it);
  - no other member mentions the parameter.

  `@Lenses` and `@Traversals` also accept a parameter constrained to `Sendable`. `@Isomorphism` accepts only an unconstrained parameter, and at least one property must have exactly the parameter's type.
- `Optic.Field` is a stored part of a value. It changes the part where it is stored, where `Optic.Lens.set` rebuilds the whole from a copy, and it carries an identity: positions known when the program is compiled, so two fields can be compared without comparing closures. `appending(_:)` composes two fields and appends their positions. `lens` gives the same part as an `Optic.Lens`.
- `@Fields` derives one field for each stored instance `var` of a struct, as a member of `Fields`, and makes the struct conform to `Optic.Field.Accessible`. It needs no type annotation and no memberwise initializer, because it never rebuilds the struct.
  - A field's position is its property's place among the stored instance properties, in declaration order. A `let` gets no field but keeps its position, and so does a property with an attribute (a property wrapper or an attached macro may make it read-only, which the derivation cannot see); a computed, `lazy` or static property takes none.
  - A struct written with a global actor attribute, such as `@MainActor`, gets a namespace, an accessor and a conformance isolated to that actor, because a nested type does not take its enclosing type's isolation. The attribute is recognised by its name ending in `Actor`.
  - Generic code takes a part of any such type as a function of the namespace, `(Whole.Fields) -> Optic<Whole, Whole, Part, Part>.Field`, which a caller writes as `{ $0.name }`.
- `@Prisms` makes the enum conform to `Optic.Prism.Accessible`, so an `Optic.Prism` whose focus is that enum can reach the enum's cases by member name. Reading a case directly off a value as an optional also requires that the enum be declared `@dynamicMemberLookup` and that both the enum and the payload be copyable. A member the enum already declares takes precedence over the case of the same name.
- `Prisms<Represented>.rawValue` matches every raw value that has a case. Any other raw value comes back unchanged on the left.
- `transporting(_:)` gives a lawful `Algebra.Monoid` only when the isomorphism is lawful.
