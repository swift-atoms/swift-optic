# Optic

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Ownership-aware, polymorphic optics for Swift. The family
`Optic<Source, Target, Focus, Replacement>` models both the value being
inspected and the value reconstructed after a focus changes.

```swift
import Optic

struct User {
    var name: String
    var age: Int
}

let name = Optic<User, User, String, String>.Lens { user in
    (
        focus: user.name,
        reconstruct: { replacement in
            var user = user
            user.name = replacement
            return user
        }
    )
}

let renamed = name.set(User(name: "Blob", age: 1), "Blob Jr.")
```

The four sorts need not be equal. A polymorphic lens can replace an `Int`
focus with a `String` and consequently reconstruct a different target type:

```swift
struct Box<Value> { var value: Value }

let value = Optic<Box<Int>, Box<String>, Int, String>.Lens { box in
    (
        focus: box.value,
        reconstruct: { Box<String>(value: $0) }
    )
}
```

## Ownership

The outer `Optic` family admits `~Copyable & ~Escapable` in all four
positions. `Source` and `Replacement` remain consumed inputs throughout the
core representations. Stored escaping arrows currently require `Target` and
`Focus` result positions to be `Escapable`; a focused compiler fixture records
the Swift 6.4 lifetime limitation that makes this restriction unavoidable.

`Prism.match` consumes its source and returns `Either<Target, Focus>`. The left
branch preserves the unmatched source as its already-transformed target, while
the right branch carries the focus. `Prism.embed` consumes a replacement.

```swift
enum Route { case home, user(Int) }

let user = Optic<Route, Route, Int, Int>.Prism(
    match: {
        switch $0 {
        case .home: return .left(.home)
        case let .user(id): return .right(id)
        }
    },
    embed: Route.user
)
```

## Optic kinds

| Kind | Representation and law claim |
|------|------------------------------|
| `Adapter<ForwardFailure, BackwardFailure>` | independent, lawless `Source → Focus` and `Replacement → Target` arrows with independently typed failures |
| `Isomorphism` | lawful bidirectional adapter |
| `Lens` | one focus plus a replacement-driven reconstruction closure |
| `Prism` | `Either<Target, Focus>` match plus replacement embedding |
| `Affine` | zero-or-one focus with reconstruction when present |
| `Traversal` | an ordered focus array plus replacement-array reconstruction |
| `Setter` | write-oriented transformation over copyable, escapable focuses |

Adapter directions infer `Never` when their closures cannot fail, so a total
direction is called without `try`. Composition normalizes each failure axis
independently:

```text
Never + Never = Never
Never + E     = E
E + Never     = E
E1 + E2       = Either<E1, E2>
```

When both adapters can fail, `.left` identifies the first adapter and `.right`
the second in both directions. The origin convention is stable even though the
second backward arrow executes first.

`>>>` and `appending` support this law-preserving core matrix:

| First ↓ / Second → | Adapter | Isomorphism | Prism |
|---|---:|---:|---:|
| Adapter | Adapter | Adapter | unavailable |
| Isomorphism | Adapter | Isomorphism | Prism |
| Prism | unavailable | Prism | Prism |

Mixed Adapter/Prism composition is intentionally absent because an arbitrary
adapter cannot preserve Prism laws. Isomorphism can be weakened losslessly to
`Adapter<Never, Never>` or to Prism.

Nominal integrations expose domain optics through `Nest.Name` access:

```swift
String.isomorphisms.substring
Represented.prisms.rawValue
Optic<Value, Value, Void, Void>.Prism.fixed(value)
```

Derived enum cases use `Root.prisms.caseName`; derived exact stored-property
representations use `Root.isomorphisms.memberwise`. `Optional` and `Result`
also provide `.prisms` access, and conforming sum types can expose dynamic
member prism chains and pattern matching with `~=`.

There is intentionally no `Iso` compatibility spelling; the public name is
`Isomorphism`.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-optic.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Optic", package: "swift-optic"),
    ]
)
```

Requires Swift 6.4 and macOS 27 / iOS 27 / tvOS 27 / watchOS 27 / visionOS 27
(or a matching non-Apple toolchain). The package depends on
[`swift-either`](https://github.com/swift-atoms/swift-either).

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
